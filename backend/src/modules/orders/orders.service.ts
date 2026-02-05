import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectQueue } from '@nestjs/bull';
import { Queue } from 'bull';
import { PrismaService } from '../../prisma/prisma.service';
import { SmartDispatchService } from './smart-dispatch.service';
import { CreateOrderDto, PaymentCallbackDto } from './dto';
import { OrderResponse } from './responses';
import { OrderStatus, PaymentStatus, PianoStatus } from '@prisma/client';

@Injectable()
export class OrdersService {
    constructor(
        private readonly prisma: PrismaService,
        private readonly smartDispatch: SmartDispatchService,
        @InjectQueue('commission-queue') private commissionQueue: Queue,
    ) { }

    /**
     * Create new rental order with smart dispatch
     */
    async createOrder(userId: string, dto: CreateOrderDto): Promise<OrderResponse> {
        // 1. Find nearest warehouses
        const warehouses = await this.smartDispatch.findNearestWarehouses({
            lat: dto.deliveryLat,
            lng: dto.deliveryLng,
            pianoType: dto.pianoType,
            radiusKm: 50,
        });

        if (!warehouses.length) {
            throw new NotFoundException('Không tìm thấy kho đàn gần bạn trong bán kính 50km');
        }

        const selectedWarehouse = warehouses[0];

        // 2. Select piano
        let selectedPiano;
        if (dto.pianoId) {
            selectedPiano = await this.prisma.piano.findFirst({
                where: {
                    id: dto.pianoId,
                    warehouseId: selectedWarehouse.id,
                    status: PianoStatus.available,
                },
            });
            if (!selectedPiano) {
                throw new NotFoundException('Đàn này không còn available');
            }
        } else {
            // Get first available piano
            selectedPiano = await this.prisma.piano.findFirst({
                where: {
                    warehouseId: selectedWarehouse.id,
                    status: PianoStatus.available,
                    ...(dto.pianoType !== 'any' && { keysCount: parseInt(dto.pianoType) }),
                },
            });
            if (!selectedPiano) {
                throw new NotFoundException('Không có đàn phù hợp');
            }
        }

        // 3. Calculate pricing
        const rentalDays = this.calculateDays(dto.startDate, dto.endDate);
        const rentalAmount = Number(selectedPiano.dailyRate) * rentalDays;
        const shippingAmount = this.calculateShipping(selectedWarehouse.distanceKm);
        const insuranceAmount = rentalAmount * 0.05; // 5%
        const totalAmount = rentalAmount + shippingAmount + insuranceAmount;

        // 4. Get user referrer for commission tracking
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            select: { referrerId: true },
        });

        // 5. Create order in transaction
        const order = await this.prisma.executeTransaction(async (tx) => {
            // Create order
            const newOrder = await tx.order.create({
                data: {
                    studentId: userId,
                    warehouseId: selectedWarehouse.id,
                    pianoId: selectedPiano.id,
                    startDate: dto.startDate,
                    endDate: dto.endDate,
                    deliveryAddress: dto.deliveryAddress,
                    deliveryLat: dto.deliveryLat,
                    deliveryLng: dto.deliveryLng,
                    deliveryDistanceKm: selectedWarehouse.distanceKm,
                    rentalDays,
                    dailyRate: selectedPiano.dailyRate,
                    rentalAmount,
                    shippingAmount,
                    insuranceAmount,
                    totalAmount,
                    depositAmount: selectedPiano.depositAmount,
                    status: OrderStatus.pending,
                    paymentStatus: PaymentStatus.pending,
                    referrerId: user?.referrerId,
                    customerNote: dto.customerNote,
                },
                include: {
                    piano: true,
                    warehouse: true,
                    student: {
                        select: {
                            id: true,
                            fullName: true,
                            phone: true,
                            email: true,
                        },
                    },
                },
            });

            // Reserve piano
            await tx.piano.update({
                where: { id: selectedPiano.id },
                data: {
                    status: PianoStatus.rented,
                    currentOrderId: newOrder.id,
                },
            });

            return newOrder;
        });

        return this.mapOrderToResponse(order);
    }

    /**
     * Handle payment callback from VNPay/Momo
     */
    async handlePaymentCallback(payload: PaymentCallbackDto): Promise<void> {
        const order = await this.prisma.order.findFirst({
            where: { id: payload.orderId },
        });

        if (!order) {
            throw new NotFoundException('Order not found');
        }

        if (payload.status === 'success') {
            // Update order
            await this.prisma.order.update({
                where: { id: order.id },
                data: {
                    paymentStatus: PaymentStatus.paid,
                    paymentTransactionId: payload.transactionId,
                    paidAt: new Date(),
                    status: OrderStatus.paid,
                },
            });

            // Trigger commission calculation via queue
            if (order.referrerId) {
                await this.commissionQueue.add('process-commission', {
                    orderId: order.id,
                    orderAmount: Number(order.totalAmount),
                    userId: order.studentId,
                    referrerId: order.referrerId,
                });
            }
        } else {
            // Payment failed - release piano
            await this.prisma.executeTransaction(async (tx) => {
                await tx.order.update({
                    where: { id: order.id },
                    data: {
                        paymentStatus: PaymentStatus.failed,
                        status: OrderStatus.cancelled,
                    },
                });

                await tx.piano.update({
                    where: { id: order.pianoId },
                    data: {
                        status: PianoStatus.available,
                        currentOrderId: null,
                    },
                });
            });
        }
    }

    /**
     * Get user orders
     */
    async getUserOrders(userId: string, status?: string): Promise<OrderResponse[]> {
        const orders = await this.prisma.order.findMany({
            where: {
                studentId: userId,
                ...(status && { status: status as OrderStatus }),
            },
            include: {
                piano: true,
                warehouse: true,
            },
            orderBy: { createdAt: 'desc' },
        });

        return orders.map(this.mapOrderToResponse);
    }

    /**
     * Get order by ID
     */
    async getOrderById(orderId: string, userId: string): Promise<OrderResponse> {
        const order = await this.prisma.order.findFirst({
            where: {
                id: orderId,
                studentId: userId,
            },
            include: {
                piano: true,
                warehouse: true,
                student: {
                    select: {
                        id: true,
                        fullName: true,
                        phone: true,
                        email: true,
                    },
                },
            },
        });

        if (!order) {
            throw new NotFoundException('Order not found');
        }

        return this.mapOrderToResponse(order);
    }

    /**
     * Cancel order
     */
    async cancelOrder(orderId: string, userId: string): Promise<OrderResponse> {
        const order = await this.prisma.order.findFirst({
            where: {
                id: orderId,
                studentId: userId,
            },
        });

        if (!order) {
            throw new NotFoundException('Order not found');
        }

        if (order.status !== OrderStatus.pending) {
            throw new BadRequestException('Chỉ có thể hủy đơn hàng ở trạng thái pending');
        }

        const updated = await this.prisma.executeTransaction(async (tx) => {
            const updatedOrder = await tx.order.update({
                where: { id: orderId },
                data: { status: OrderStatus.cancelled },
                include: {
                    piano: true,
                    warehouse: true,
                },
            });

            // Release piano
            await tx.piano.update({
                where: { id: order.pianoId },
                data: {
                    status: PianoStatus.available,
                    currentOrderId: null,
                },
            });

            return updatedOrder;
        });

        return this.mapOrderToResponse(updated);
    }

    // === HELPERS ===

    private calculateDays(start: Date, end: Date): number {
        const diff = new Date(end).getTime() - new Date(start).getTime();
        return Math.ceil(diff / (1000 * 60 * 60 * 24));
    }

    private calculateShipping(distanceKm: number): number {
        if (distanceKm < 5) return 50000;
        if (distanceKm < 15) return 100000;
        if (distanceKm < 30) return 150000;
        return 200000;
    }

    private mapOrderToResponse(order: any): OrderResponse {
        return {
            id: order.id,
            orderNumber: order.orderNumber,
            status: order.status,
            paymentStatus: order.paymentStatus,
            piano: order.piano ? {
                id: order.piano.id,
                brand: order.piano.brand,
                model: order.piano.model,
                keysCount: order.piano.keysCount,
                images: order.piano.images as string[],
            } : undefined,
            warehouse: order.warehouse ? {
                id: order.warehouse.id,
                name: order.warehouse.name,
                address: order.warehouse.address,
            } : undefined,
            startDate: order.startDate,
            endDate: order.endDate,
            deliveryAddress: order.deliveryAddress,
            rentalAmount: Number(order.rentalAmount),
            shippingAmount: Number(order.shippingAmount),
            insuranceAmount: Number(order.insuranceAmount),
            totalAmount: Number(order.totalAmount),
            createdAt: order.createdAt,
        };
    }
}
