import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bull';
import { CommissionProcessor } from './commission.processor';
import { CommissionService } from './commission.service';
import { WalletModule } from '../wallet/wallet.module';

@Module({
    imports: [
        BullModule.registerQueue({
            name: 'commission-queue',
        }),
        WalletModule,
    ],
    providers: [CommissionProcessor, CommissionService],
    exports: [CommissionService],
})
export class CommissionModule { }
