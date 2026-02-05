import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsNumber, IsString, IsOptional, IsDateString, IsEnum } from 'class-validator';

export class FindNearestWarehousesDto {
    @ApiProperty({ example: 21.0285, description: 'Latitude của địa chỉ giao hàng' })
    @IsNumber()
    @IsNotEmpty()
    lat: number;

    @ApiProperty({ example: 105.8542, description: 'Longitude của địa chỉ giao hàng' })
    @IsNumber()
    @IsNotEmpty()
    lng: number;

    @ApiProperty({ example: 'any', enum: ['any', '61', '88'], required: false })
    @IsEnum(['any', '61', '88'])
    @IsOptional()
    pianoType?: 'any' | '61' | '88';

    @ApiProperty({ example: 50, required: false, description: 'Bán kính tìm kiếm (km)' })
    @IsNumber()
    @IsOptional()
    radiusKm?: number;
}

export class CreateOrderDto {
    @ApiProperty({ required: false, description: 'ID đàn cụ thể (nếu có)' })
    @IsString()
    @IsOptional()
    pianoId?: string;

    @ApiProperty({ example: 'any', enum: ['any', '61', '88'] })
    @IsEnum(['any', '61', '88'])
    @IsOptional()
    pianoType?: 'any' | '61' | '88';

    @ApiProperty({ example: '2026-02-10' })
    @IsDateString()
    @IsNotEmpty()
    startDate: Date;

    @ApiProperty({ example: '2026-03-10' })
    @IsDateString()
    @IsNotEmpty()
    endDate: Date;

    @ApiProperty({ example: '123 Xuân Thủy, Cầu Giấy, Hà Nội' })
    @IsString()
    @IsNotEmpty()
    deliveryAddress: string;

    @ApiProperty({ example: 21.0356 })
    @IsNumber()
    @IsNotEmpty()
    deliveryLat: number;

    @ApiProperty({ example: 105.7827 })
    @IsNumber()
    @IsNotEmpty()
    deliveryLng: number;

    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    customerNote?: string;
}

export class PaymentCallbackDto {
    @ApiProperty()
    @IsString()
    @IsNotEmpty()
    orderId: string;

    @ApiProperty()
    @IsString()
    @IsNotEmpty()
    transactionId: string;

    @ApiProperty({ enum: ['success', 'failed'] })
    @IsEnum(['success', 'failed'])
    @IsNotEmpty()
    status: 'success' | 'failed';

    @ApiProperty({ required: false })
    @IsString()
    @IsOptional()
    message?: string;
}
