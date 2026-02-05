import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { BullModule } from '@nestjs/bull';
import { ScheduleModule } from '@nestjs/schedule';

// Core
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';

// Features
import { UsersModule } from './modules/users/users.module';
import { OrdersModule } from './modules/orders/orders.module';
import { WarehousesModule } from './modules/warehouses/warehouses.module';
import { PianosModule } from './modules/pianos/pianos.module';
import { AffiliateModule } from './modules/affiliate/affiliate.module';
import { WalletModule } from './modules/wallet/wallet.module';
import { ClassroomModule } from './modules/classroom/classroom.module';
import { CommissionModule } from './modules/commission/commission.module';

@Module({
    imports: [
        // Config
        ConfigModule.forRoot({
            isGlobal: true,
            envFilePath: '.env',
        }),

        // Bull Queue (Redis)
        BullModule.forRoot({
            redis: {
                host: process.env.REDIS_HOST || 'localhost',
                port: parseInt(process.env.REDIS_PORT || '6379'),
                password: process.env.REDIS_PASSWORD,
            },
        }),

        // Schedule
        ScheduleModule.forRoot(),

        // Core
        PrismaModule,
        AuthModule,

        // Features
        UsersModule,
        OrdersModule,
        WarehousesModule,
        PianosModule,
        AffiliateModule,
        WalletModule,
        ClassroomModule,
        CommissionModule,
    ],
})
export class AppModule { }
