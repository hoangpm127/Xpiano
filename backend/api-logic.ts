// ============================================
// XPIANO MVP - API ENDPOINT LOGIC
// Backend: Node.js + NestJS
// Version: 1.0
// ============================================

// ============================================
// 1. SMART DISPATCH API - Tìm Warehouse gần nhất
// ============================================

/**
 * POST /api/orders/dispatch
 * 
 * Flow:
 * 1. User gửi địa chỉ giao hàng (lat, lng)
 * 2. Tìm warehouses có đàn available trong bán kính
 * 3. Sắp xếp theo khoảng cách
 * 4. Tạo đơn hàng với warehouse gần nhất
 */

// === DTOs ===
interface CreateOrderDto {
    pianoId?: string;          // Optional: specific piano
    pianoType?: 'any' | '61' | '88';  // Or piano type
    startDate: Date;
    endDate: Date;
    deliveryAddress: string;
    deliveryLat: number;
    deliveryLng: number;
    customerNote?: string;
}

interface NearestWarehouseResult {
    warehouseId: string;
    warehouseName: string;
    distanceKm: number;
    estimatedDeliveryHours: number;
    availablePianos: Piano[];
}

// === Controller ===
@Controller('api/orders')
export class OrdersController {
    constructor(
        private readonly ordersService: OrdersService,
        private readonly dispatchService: SmartDispatchService,
        private readonly commissionService: CommissionService,
    ) { }

    /**
     * STEP 1: Find nearest warehouses with available pianos
     */
    @Post('find-nearest')
    async findNearestWarehouses(
        @Body() dto: { lat: number; lng: number; pianoType?: string; radiusKm?: number }
    ): Promise<NearestWarehouseResult[]> {
        const { lat, lng, pianoType = 'any', radiusKm = 50 } = dto;

        // SQL with PostGIS - Find warehouses within radius, ordered by distance
        const query = `
      SELECT 
        w.id,
        w.name,
        w.address,
        w.available_pianos,
        ST_Distance(
          w.location, 
          ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography
        ) / 1000 as distance_km,
        -- Get available pianos in this warehouse
        (
          SELECT json_agg(p.*)
          FROM pianos p 
          WHERE p.warehouse_id = w.id 
          AND p.status = 'available'
          ${pianoType !== 'any' ? `AND p.keys_count = ${pianoType}` : ''}
        ) as available_pianos
      FROM warehouses w
      WHERE w.is_active = true
      AND w.available_pianos > 0
      AND ST_DWithin(
        w.location,
        ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography,
        $3 * 1000  -- Convert km to meters
      )
      ORDER BY distance_km ASC
      LIMIT 5
    `;

        const results = await this.db.query(query, [lng, lat, radiusKm]);

        return results.map(r => ({
            warehouseId: r.id,
            warehouseName: r.name,
            distanceKm: parseFloat(r.distance_km.toFixed(2)),
            estimatedDeliveryHours: this.calculateDeliveryTime(r.distance_km),
            availablePianos: r.available_pianos || [],
        }));
    }

    /**
     * STEP 2: Create order with auto-dispatch
     */
    @Post('create')
    @UseGuards(AuthGuard)
    async createOrder(
        @CurrentUser() user: User,
        @Body() dto: CreateOrderDto
    ): Promise<Order> {
        // Find nearest warehouse
        const nearestWarehouses = await this.findNearestWarehouses({
            lat: dto.deliveryLat,
            lng: dto.deliveryLng,
            pianoType: dto.pianoType,
        });

        if (nearestWarehouses.length === 0) {
            throw new NotFoundException('Không tìm thấy kho đàn gần bạn');
        }

        const selectedWarehouse = nearestWarehouses[0];

        // Select piano (specific or first available)
        let selectedPiano: Piano;
        if (dto.pianoId) {
            selectedPiano = selectedWarehouse.availablePianos.find(p => p.id === dto.pianoId);
            if (!selectedPiano) {
                throw new NotFoundException('Đàn này không còn available');
            }
        } else {
            selectedPiano = selectedWarehouse.availablePianos[0];
        }

        // Calculate pricing
        const rentalDays = this.calculateDays(dto.startDate, dto.endDate);
        const rentalAmount = selectedPiano.daily_rate * rentalDays;
        const shippingAmount = this.calculateShipping(selectedWarehouse.distanceKm);
        const insuranceAmount = rentalAmount * 0.05; // 5% insurance
        const totalAmount = rentalAmount + shippingAmount + insuranceAmount;

        // Create order in transaction
        const order = await this.db.transaction(async (tx) => {
            // 1. Create order
            const newOrder = await tx.orders.create({
                student_id: user.id,
                warehouse_id: selectedWarehouse.warehouseId,
                piano_id: selectedPiano.id,
                start_date: dto.startDate,
                end_date: dto.endDate,
                delivery_address: dto.deliveryAddress,
                delivery_lat: dto.deliveryLat,
                delivery_lng: dto.deliveryLng,
                delivery_distance_km: selectedWarehouse.distanceKm,
                rental_days: rentalDays,
                daily_rate: selectedPiano.daily_rate,
                rental_amount: rentalAmount,
                shipping_amount: shippingAmount,
                insurance_amount: insuranceAmount,
                total_amount: totalAmount,
                status: 'pending',
                payment_status: 'pending',
                referrer_id: user.referrer_id, // Track for commission
                customer_note: dto.customerNote,
            });

            // 2. Reserve piano (change status to prevent double booking)
            await tx.pianos.update({
                where: { id: selectedPiano.id },
                data: { status: 'rented', current_order_id: newOrder.id },
            });

            return newOrder;
        });

        // 3. Send notifications
        await this.notificationService.notifyPartner(order);
        await this.notificationService.notifyStudent(order);

        return order;
    }

    /**
     * STEP 3: Process payment callback
     * Called by VNPay/Momo after successful payment
     */
    @Post('payment-callback')
    async handlePaymentCallback(
        @Body() payload: PaymentCallbackDto
    ): Promise<void> {
        const order = await this.ordersService.findByTransactionId(payload.transactionId);

        if (!order) {
            throw new NotFoundException('Order not found');
        }

        if (payload.status === 'success') {
            // Update order
            await this.ordersService.update(order.id, {
                payment_status: 'paid',
                payment_transaction_id: payload.transactionId,
                paid_at: new Date(),
                status: 'paid',
            });

            // ⭐ TRIGGER COMMISSION CALCULATION (Background Job)
            await this.commissionQueue.add('process-commission', {
                orderId: order.id,
                orderAmount: order.total_amount,
                userId: order.student_id,
                referrerId: order.referrer_id,
            });
        }
    }

    // === Helper Methods ===
    private calculateDeliveryTime(distanceKm: number): number {
        // Rough estimate: 30 mins base + 5 mins per km
        return Math.ceil((30 + distanceKm * 5) / 60); // hours
    }

    private calculateShipping(distanceKm: number): number {
        if (distanceKm < 5) return 50000;  // 50k
        if (distanceKm < 15) return 100000; // 100k
        if (distanceKm < 30) return 150000; // 150k
        return 200000; // 200k for far distances
    }

    private calculateDays(start: Date, end: Date): number {
        const diff = end.getTime() - start.getTime();
        return Math.ceil(diff / (1000 * 60 * 60 * 24));
    }
}


// ============================================
// 2. COMMISSION TRIGGER - Background Job
// ============================================

/**
 * Queue: commission-queue
 * Job: process-commission
 * 
 * Flow:
 * 1. Order paid → Add job to queue
 * 2. Worker picks up job
 * 3. Find F1 referrer → Calculate 8-12% → Credit wallet
 * 4. Find F2 referrer → Calculate 5% → Credit wallet
 * 5. Insert commission records for transparency
 */

@Processor('commission-queue')
export class CommissionProcessor {
    constructor(
        private readonly commissionService: CommissionService,
        private readonly walletService: WalletService,
        private readonly userService: UserService,
    ) { }

    // Commission rates
    private readonly TIER_1_RATE = 0.10; // 10% for F1
    private readonly TIER_2_RATE = 0.05; // 5% for F2

    @Process('process-commission')
    async processCommission(job: Job<CommissionJobData>): Promise<void> {
        const { orderId, orderAmount, userId, referrerId } = job.data;

        console.log(`Processing commission for order ${orderId}`);

        // Skip if no referrer
        if (!referrerId) {
            console.log('No referrer found, skipping commission');
            await this.markOrderProcessed(orderId);
            return;
        }

        try {
            await this.db.transaction(async (tx) => {
                // ========== TIER 1 COMMISSION (F1) ==========
                const f1User = await tx.users.findUnique({
                    where: { id: referrerId },
                    include: { wallet: true },
                });

                if (f1User) {
                    const tier1Amount = orderAmount * this.TIER_1_RATE;

                    // 1. Create commission record
                    const tier1Commission = await tx.commissions.create({
                        order_id: orderId,
                        affiliate_id: f1User.id,
                        source_user_id: userId,
                        tier: 1,
                        order_amount: orderAmount,
                        commission_rate: this.TIER_1_RATE * 100, // Store as percentage
                        commission_amount: tier1Amount,
                        status: 'approved',
                        approved_at: new Date(),
                    });

                    // 2. Credit wallet
                    await this.walletService.credit(
                        tx,
                        f1User.id,
                        tier1Amount,
                        {
                            type: 'commission',
                            referenceType: 'commission',
                            referenceId: tier1Commission.id,
                            description: `Hoa hồng Tier 1 từ đơn hàng ${orderId.slice(0, 8)}`,
                        }
                    );

                    console.log(`Tier 1 commission ${tier1Amount} credited to ${f1User.full_name}`);

                    // ========== TIER 2 COMMISSION (F2) ==========
                    if (f1User.referrer_id) {
                        const f2User = await tx.users.findUnique({
                            where: { id: f1User.referrer_id },
                            include: { wallet: true },
                        });

                        if (f2User) {
                            const tier2Amount = orderAmount * this.TIER_2_RATE;

                            // 1. Create commission record
                            const tier2Commission = await tx.commissions.create({
                                order_id: orderId,
                                affiliate_id: f2User.id,
                                source_user_id: userId,
                                tier: 2,
                                order_amount: orderAmount,
                                commission_rate: this.TIER_2_RATE * 100,
                                commission_amount: tier2Amount,
                                status: 'approved',
                                approved_at: new Date(),
                            });

                            // 2. Credit wallet
                            await this.walletService.credit(
                                tx,
                                f2User.id,
                                tier2Amount,
                                {
                                    type: 'commission',
                                    referenceType: 'commission',
                                    referenceId: tier2Commission.id,
                                    description: `Hoa hồng Tier 2 từ đơn hàng ${orderId.slice(0, 8)}`,
                                }
                            );

                            console.log(`Tier 2 commission ${tier2Amount} credited to ${f2User.full_name}`);
                        }
                    }
                }

                // Mark order as commission processed
                await tx.orders.update({
                    where: { id: orderId },
                    data: { commission_processed: true },
                });
            });

        } catch (error) {
            console.error('Commission processing failed:', error);
            throw error; // Bull will retry
        }
    }
}


// ============================================
// 3. WALLET SERVICE - Credit/Debit Operations
// ============================================

@Injectable()
export class WalletService {
    /**
     * Credit money to wallet (add balance)
     */
    async credit(
        tx: PrismaTransaction, // Transaction context
        userId: string,
        amount: number,
        meta: {
            type: 'commission' | 'refund' | 'bonus';
            referenceType: string;
            referenceId: string;
            description: string;
        }
    ): Promise<WalletTransaction> {
        // Get current wallet
        const wallet = await tx.wallets.findUnique({
            where: { user_id: userId },
        });

        if (!wallet) {
            throw new NotFoundException('Wallet not found');
        }

        const balanceBefore = wallet.balance;
        const balanceAfter = balanceBefore + amount;

        // Update wallet balance
        await tx.wallets.update({
            where: { id: wallet.id },
            data: {
                balance: balanceAfter,
                total_earned: wallet.total_earned + amount,
            },
        });

        // Create transaction record
        const transaction = await tx.wallet_transactions.create({
            wallet_id: wallet.id,
            type: meta.type,
            direction: 'credit',
            amount: amount,
            balance_before: balanceBefore,
            balance_after: balanceAfter,
            reference_type: meta.referenceType,
            reference_id: meta.referenceId,
            description: meta.description,
            status: 'completed',
        });

        return transaction;
    }

    /**
     * Debit money from wallet (withdraw)
     */
    async debit(
        userId: string,
        amount: number,
        meta: {
            type: 'withdrawal';
            description: string;
        }
    ): Promise<WalletTransaction> {
        return this.db.transaction(async (tx) => {
            const wallet = await tx.wallets.findUnique({
                where: { user_id: userId },
            });

            if (!wallet) {
                throw new NotFoundException('Wallet not found');
            }

            if (wallet.balance < amount) {
                throw new BadRequestException('Số dư không đủ');
            }

            const balanceBefore = wallet.balance;
            const balanceAfter = balanceBefore - amount;

            // Update wallet
            await tx.wallets.update({
                where: { id: wallet.id },
                data: {
                    balance: balanceAfter,
                    total_withdrawn: wallet.total_withdrawn + amount,
                },
            });

            // Create transaction record
            return tx.wallet_transactions.create({
                wallet_id: wallet.id,
                type: 'withdrawal',
                direction: 'debit',
                amount: amount,
                balance_before: balanceBefore,
                balance_after: balanceAfter,
                description: meta.description,
                status: 'pending', // Will be completed after bank transfer
            });
        });
    }
}


// ============================================
// 4. AFFILIATE CONTROLLER - Dashboard APIs
// ============================================

@Controller('api/affiliate')
@UseGuards(AuthGuard)
export class AffiliateController {
    /**
     * GET /api/affiliate/dashboard
     * Get affiliate stats for current user
     */
    @Get('dashboard')
    async getDashboard(@CurrentUser() user: User): Promise<AffiliateDashboard> {
        // Count F1 (direct referrals)
        const f1Count = await this.db.users.count({
            where: { referrer_id: user.id },
        });

        // Count F2 (referrals of referrals)
        const f2Count = await this.db.users.count({
            where: {
                referrer_id: {
                    in: await this.db.users.findMany({
                        where: { referrer_id: user.id },
                        select: { id: true },
                    }).then(users => users.map(u => u.id)),
                },
            },
        });

        // Get wallet
        const wallet = await this.db.wallets.findUnique({
            where: { user_id: user.id },
        });

        // Get commission stats
        const commissions = await this.db.commissions.groupBy({
            by: ['tier'],
            where: { affiliate_id: user.id },
            _sum: { commission_amount: true },
            _count: true,
        });

        // Get monthly chart data
        const monthlyData = await this.db.$queryRaw`
      SELECT 
        DATE_TRUNC('month', created_at) as month,
        SUM(commission_amount) as total
      FROM commissions
      WHERE affiliate_id = ${user.id}
      AND created_at >= NOW() - INTERVAL '12 months'
      GROUP BY DATE_TRUNC('month', created_at)
      ORDER BY month
    `;

        return {
            referralCode: user.referral_code,
            referralLink: `https://xpiano.vn/ref/${user.referral_code}`,
            f1Count,
            f2Count,
            totalReferrals: f1Count + f2Count,
            wallet: {
                balance: wallet.balance,
                pendingBalance: wallet.pending_balance,
                totalEarned: wallet.total_earned,
            },
            commissionsByTier: {
                tier1: commissions.find(c => c.tier === 1)?._sum?.commission_amount || 0,
                tier2: commissions.find(c => c.tier === 2)?._sum?.commission_amount || 0,
            },
            monthlyEarnings: monthlyData,
        };
    }

    /**
     * GET /api/affiliate/network
     * Get referral tree (F1 and F2 users)
     */
    @Get('network')
    async getNetwork(@CurrentUser() user: User): Promise<AffiliateNetwork> {
        // Get F1 users
        const f1Users = await this.db.users.findMany({
            where: { referrer_id: user.id },
            select: {
                id: true,
                full_name: true,
                avatar_url: true,
                created_at: true,
                _count: {
                    select: { referred_users: true }, // Count their F2s
                },
            },
        });

        // Get F2 users for each F1
        const f1WithF2 = await Promise.all(
            f1Users.map(async (f1) => {
                const f2Users = await this.db.users.findMany({
                    where: { referrer_id: f1.id },
                    select: {
                        id: true,
                        full_name: true,
                        avatar_url: true,
                        created_at: true,
                    },
                });

                return {
                    ...f1,
                    tier: 1,
                    f2Count: f2Users.length,
                    children: f2Users.map(f2 => ({ ...f2, tier: 2 })),
                };
            })
        );

        return {
            totalF1: f1Users.length,
            totalF2: f1WithF2.reduce((sum, f1) => sum + f1.f2Count, 0),
            tree: f1WithF2,
        };
    }

    /**
     * GET /api/affiliate/leaderboard
     * Top affiliates of the month
     */
    @Get('leaderboard')
    async getLeaderboard(): Promise<LeaderboardEntry[]> {
        const leaderboard = await this.db.$queryRaw`
      SELECT 
        u.id,
        u.full_name,
        u.avatar_url,
        SUM(c.commission_amount) as total_earned,
        COUNT(DISTINCT c.source_user_id) as referral_count
      FROM users u
      JOIN commissions c ON u.id = c.affiliate_id
      WHERE c.created_at >= DATE_TRUNC('month', NOW())
      GROUP BY u.id, u.full_name, u.avatar_url
      ORDER BY total_earned DESC
      LIMIT 10
    `;

        return leaderboard.map((entry, index) => ({
            rank: index + 1,
            ...entry,
        }));
    }

    /**
     * POST /api/affiliate/withdraw
     * Request withdrawal to bank account
     */
    @Post('withdraw')
    async requestWithdrawal(
        @CurrentUser() user: User,
        @Body() dto: { amount: number; bankAccount: string; bankName: string }
    ): Promise<{ message: string; transactionId: string }> {
        const MIN_WITHDRAWAL = 100000; // 100k VND

        if (dto.amount < MIN_WITHDRAWAL) {
            throw new BadRequestException(`Số tiền rút tối thiểu là ${MIN_WITHDRAWAL.toLocaleString()}đ`);
        }

        const transaction = await this.walletService.debit(user.id, dto.amount, {
            type: 'withdrawal',
            description: `Rút về ${dto.bankName} - ${dto.bankAccount}`,
        });

        // Queue bank transfer (async)
        await this.bankTransferQueue.add('process-withdrawal', {
            transactionId: transaction.id,
            userId: user.id,
            amount: dto.amount,
            bankAccount: dto.bankAccount,
            bankName: dto.bankName,
        });

        return {
            message: 'Yêu cầu rút tiền đã được ghi nhận. Tiền sẽ về tài khoản trong 1-3 ngày làm việc.',
            transactionId: transaction.id,
        };
    }
}


// ============================================
// 5. CLASSROOM SESSION CONTROLLER
// ============================================

@Controller('api/classroom')
@UseGuards(AuthGuard)
export class ClassroomController {
    /**
     * POST /api/classroom/join
     * Join a class session (WebRTC signaling)
     */
    @Post('join/:sessionId')
    async joinSession(
        @CurrentUser() user: User,
        @Param('sessionId') sessionId: string
    ): Promise<JoinSessionResponse> {
        const session = await this.db.class_sessions.findUnique({
            where: { id: sessionId },
            include: { teacher: true, student: true },
        });

        if (!session) {
            throw new NotFoundException('Session not found');
        }

        // Verify user is participant
        if (session.student_id !== user.id && session.teacher_id !== user.id) {
            throw new ForbiddenException('Bạn không có quyền tham gia buổi học này');
        }

        // Generate room credentials
        const roomId = `xp-${sessionId.slice(0, 8)}`;
        const role = session.teacher_id === user.id ? 'teacher' : 'student';

        // Get TURN server credentials
        const iceServers = await this.webrtcService.getIceServers();

        return {
            roomId,
            role,
            iceServers,
            sessionInfo: {
                teacherName: session.teacher.full_name,
                studentName: session.student.full_name,
                scheduledAt: session.scheduled_at,
                durationMinutes: session.duration_minutes,
            },
        };
    }

    /**
     * POST /api/classroom/start-recording
     * Start recording the session
     */
    @Post(':sessionId/start-recording')
    async startRecording(
        @Param('sessionId') sessionId: string
    ): Promise<{ recordingId: string }> {
        const recordingId = await this.recordingService.start(sessionId);

        await this.db.class_sessions.update({
            where: { id: sessionId },
            data: {
                status: 'in_progress',
                actual_start_at: new Date(),
            },
        });

        return { recordingId };
    }

    /**
     * POST /api/classroom/end
     * End class session
     */
    @Post(':sessionId/end')
    async endSession(
        @Param('sessionId') sessionId: string
    ): Promise<{ message: string }> {
        const session = await this.db.class_sessions.findUnique({
            where: { id: sessionId },
        });

        // Stop recording
        const recordingUrl = await this.recordingService.stop(sessionId);

        // Calculate actual duration
        const actualDuration = Math.ceil(
            (Date.now() - session.actual_start_at.getTime()) / (1000 * 60)
        );

        // Update session
        await this.db.class_sessions.update({
            where: { id: sessionId },
            data: {
                status: 'completed',
                actual_end_at: new Date(),
                recording_url: recordingUrl,
            },
        });

        // Process teacher payment
        await this.paymentQueue.add('teacher-payout', {
            sessionId,
            teacherId: session.teacher_id,
            amount: session.teacher_earning,
        });

        // Trigger commission if referred
        if (session.referrer_id) {
            await this.commissionQueue.add('process-commission', {
                orderId: sessionId, // Using session ID as order reference
                orderAmount: session.price,
                userId: session.student_id,
                referrerId: session.referrer_id,
            });
        }

        return { message: 'Buổi học đã kết thúc' };
    }
}


// ============================================
// TYPES & INTERFACES
// ============================================

interface CommissionJobData {
    orderId: string;
    orderAmount: number;
    userId: string;
    referrerId: string | null;
}

interface AffiliateDashboard {
    referralCode: string;
    referralLink: string;
    f1Count: number;
    f2Count: number;
    totalReferrals: number;
    wallet: {
        balance: number;
        pendingBalance: number;
        totalEarned: number;
    };
    commissionsByTier: {
        tier1: number;
        tier2: number;
    };
    monthlyEarnings: { month: Date; total: number }[];
}

interface AffiliateNetwork {
    totalF1: number;
    totalF2: number;
    tree: AffiliateNode[];
}

interface AffiliateNode {
    id: string;
    full_name: string;
    avatar_url: string;
    created_at: Date;
    tier: 1 | 2;
    f2Count?: number;
    children?: AffiliateNode[];
}

interface LeaderboardEntry {
    rank: number;
    id: string;
    full_name: string;
    avatar_url: string;
    total_earned: number;
    referral_count: number;
}
