import {
    Controller,
    Get,
    Post,
    Body,
    Param,
    Query,
    UseGuards,
    HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { OrdersService } from './orders.service';
import { SmartDispatchService } from './smart-dispatch.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { User } from '@prisma/client';
import {
    CreateOrderDto,
    FindNearestWarehousesDto,
    PaymentCallbackDto,
} from './dto';
import { NearestWarehouseResponse, OrderResponse } from './responses';

@ApiTags('orders')
@Controller('orders')
export class OrdersController {
    constructor(
        private readonly ordersService: OrdersService,
        private readonly smartDispatchService: SmartDispatchService,
    ) { }

    @Post('find-nearest')
    @ApiOperation({ summary: 'Tìm kho đàn gần nhất với Smart Dispatch' })
    @ApiResponse({
        status: HttpStatus.OK,
        description: 'Danh sách kho đàn gần nhất',
        type: [NearestWarehouseResponse],
    })
    async findNearest(
        @Body() dto: FindNearestWarehousesDto,
    ): Promise<NearestWarehouseResponse[]> {
        return this.smartDispatchService.findNearestWarehouses(dto);
    }

    @Post()
    @UseGuards(JwtAuthGuard)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Tạo đơn thuê đàn mới với auto-dispatch' })
    @ApiResponse({
        status: HttpStatus.CREATED,
        description: 'Đơn hàng đã được tạo',
        type: OrderResponse,
    })
    async create(
        @CurrentUser() user: User,
        @Body() dto: CreateOrderDto,
    ): Promise<OrderResponse> {
        return this.ordersService.createOrder(user.id, dto);
    }

    @Get('my-orders')
    @UseGuards(JwtAuthGuard)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Lấy danh sách đơn hàng của tôi' })
    async getMyOrders(
        @CurrentUser() user: User,
        @Query('status') status?: string,
    ): Promise<OrderResponse[]> {
        return this.ordersService.getUserOrders(user.id, status);
    }

    @Get(':id')
    @UseGuards(JwtAuthGuard)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Lấy chi tiết đơn hàng' })
    async getOrder(
        @Param('id') id: string,
        @CurrentUser() user: User,
    ): Promise<OrderResponse> {
        return this.ordersService.getOrderById(id, user.id);
    }

    @Post('payment-callback')
    @ApiOperation({ summary: 'Webhook từ payment gateway' })
    async paymentCallback(@Body() payload: PaymentCallbackDto): Promise<void> {
        await this.ordersService.handlePaymentCallback(payload);
    }

    @Post(':id/cancel')
    @UseGuards(JwtAuthGuard)
    @ApiBearerAuth()
    @ApiOperation({ summary: 'Hủy đơn hàng' })
    async cancelOrder(
        @Param('id') id: string,
        @CurrentUser() user: User,
    ): Promise<OrderResponse> {
        return this.ordersService.cancelOrder(id, user.id);
    }
}
