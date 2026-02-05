import { Process, Processor } from '@nestjs/bull';
import { Job } from 'bull';
import { Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { WalletService } from '../wallet/wallet.service';
import { CommissionStatus } from '@prisma/client';

interface CommissionJobData {
    orderId: string;
    orderAmount: number;
    userId: string;
    referrerId: string;
}

@Processor('commission-queue')
export class CommissionProcessor {
    private readonly logger = new Logger(CommissionProcessor.name);

    // Commission rates from environment
    private readonly TIER_1_RATE = Number(process.env.TIER_1_RATE) || 0.1; // 10%
    private readonly TIER_2_RATE = Number(process.env.TIER_2_RATE) || 0.05; // 5%

    constructor(
        private readonly prisma: PrismaService,
        private readonly walletService: WalletService,
    ) { }

    @Process('process-commission')
    async handleCommission(job: Job<CommissionJobData>): Promise<void> {
        const { orderId, orderAmount, userId, referrerId } = job.data;

        this.logger.log(`Processing commission for order ${orderId}`);

        // Skip if no referrer
        if (!referrerId) {
            this.logger.log('No referrer found, skipping commission');
            await this.markOrderProcessed(orderId);
            return;
        }

        try {
            await this.prisma.executeTransaction(async (tx) => {
                // ========== TIER 1 COMMISSION (F1) ==========
                const f1User = await tx.user.findUnique({
                    where: { id: referrerId },
                });

                if (!f1User) {
                    this.logger.warn(`F1 user ${referrerId} not found`);
                    return;
                }

                const tier1Amount = orderAmount * this.TIER_1_RATE;

                // 1. Create commission record
                const tier1Commission = await tx.commission.create({
                    data: {
                        orderId,
                        affiliateId: f1User.id,
                        sourceUserId: userId,
                        tier: 1,
                        orderAmount,
                        commissionRate: this.TIER_1_RATE * 100,
                        commissionAmount: tier1Amount,
                        status: CommissionStatus.approved,
                        approvedAt: new Date(),
                    },
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
                    },
                );

                this.logger.log(
                    `Tier 1 commission ${tier1Amount} VND credited to ${f1User.fullName}`,
                );

                // ========== TIER 2 COMMISSION (F2) ==========
                if (f1User.referrerId) {
                    const f2User = await tx.user.findUnique({
                        where: { id: f1User.referrerId },
                    });

                    if (f2User) {
                        const tier2Amount = orderAmount * this.TIER_2_RATE;

                        // 1. Create commission record
                        const tier2Commission = await tx.commission.create({
                            data: {
                                orderId,
                                affiliateId: f2User.id,
                                sourceUserId: userId,
                                tier: 2,
                                orderAmount,
                                commissionRate: this.TIER_2_RATE * 100,
                                commissionAmount: tier2Amount,
                                status: CommissionStatus.approved,
                                approvedAt: new Date(),
                            },
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
                            },
                        );

                        this.logger.log(
                            `Tier 2 commission ${tier2Amount} VND credited to ${f2User.fullName}`,
                        );
                    }
                }

                // Mark order as commission processed
                await tx.order.update({
                    where: { id: orderId },
                    data: { commissionProcessed: true },
                });
            });

            this.logger.log(`Commission processing completed for order ${orderId}`);
        } catch (error) {
            this.logger.error(`Commission processing failed: ${error.message}`, error.stack);
            throw error; // Bull will retry
        }
    }

    private async markOrderProcessed(orderId: string): Promise<void> {
        await this.prisma.order.update({
            where: { id: orderId },
            data: { commissionProcessed: true },
        });
    }
}
