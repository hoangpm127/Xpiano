import { ApiProperty } from '@nestjs/swagger';

export class PianoBasicInfo {
    @ApiProperty()
    id: string;

    @ApiProperty()
    brand: string;

    @ApiProperty()
    model: string;

    @ApiProperty()
    keysCount: number;

    @ApiProperty()
    dailyRate: number;

    @ApiProperty({ required: false })
    monthlyRate?: number;

    @ApiProperty({ type: [String] })
    images: string[];

    @ApiProperty()
    condition: string;

    @ApiProperty()
    avgRating: number;
}

export class WarehouseBasicInfo {
    @ApiProperty()
    id: string;

    @ApiProperty()
    name: string;

    @ApiProperty()
    address: string;

    @ApiProperty({ required: false })
    district?: string;

    @ApiProperty()
    city: string;

    @ApiProperty({ required: false })
    phone?: string;
}

export class NearestWarehouseResponse extends WarehouseBasicInfo {
    @ApiProperty({ description: 'Khoảng cách từ địa chỉ giao hàng (km)' })
    distanceKm: number;

    @ApiProperty({ description: 'Thời gian giao hàng ước tính (giờ)' })
    estimatedDeliveryHours: number;

    @ApiProperty()
    avgRating: number;

    @ApiProperty({ type: [PianoBasicInfo] })
    availablePianos: PianoBasicInfo[];
}

export class OrderResponse {
    @ApiProperty()
    id: string;

    @ApiProperty()
    orderNumber: string;

    @ApiProperty()
    status: string;

    @ApiProperty()
    paymentStatus: string;

    @ApiProperty({ type: PianoBasicInfo, required: false })
    piano?: PianoBasicInfo;

    @ApiProperty({ type: WarehouseBasicInfo, required: false })
    warehouse?: WarehouseBasicInfo;

    @ApiProperty()
    startDate: Date;

    @ApiProperty()
    endDate: Date;

    @ApiProperty()
    deliveryAddress: string;

    @ApiProperty()
    rentalAmount: number;

    @ApiProperty()
    shippingAmount: number;

    @ApiProperty()
    insuranceAmount: number;

    @ApiProperty()
    totalAmount: number;

    @ApiProperty()
    createdAt: Date;
}
