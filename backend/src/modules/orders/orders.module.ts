import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bull';
import { OrdersController } from './orders.controller';
import { OrdersService } from './orders.service';
import { SmartDispatchService } from './smart-dispatch.service';
import { CommissionModule } from '../commission/commission.module';

@Module({
    imports: [
        BullModule.registerQueue({
            name: 'commission-queue',
        }),
        CommissionModule,
    ],
    controllers: [OrdersController],
    providers: [OrdersService, SmartDispatchService],
    exports: [OrdersService],
})
export class OrdersModule { }
