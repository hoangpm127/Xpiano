import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class CommissionService {
    constructor(private readonly prisma: PrismaService) { }

    async getCommissionsByAffiliate(affiliateId: string) {
        return this.prisma.commission.findMany({
            where: { affiliateId },
            include: {
                order: {
                    select: {
                        orderNumber: true,
                        totalAmount: true,
                        createdAt: true,
                    },
                },
                sourceUser: {
                    select: {
                        fullName: true,
                    },
                },
            },
            orderBy: { createdAt: 'desc' },
        });
    }

    async getCommissionStats(affiliateId: string) {
        const stats = await this.prisma.commission.groupBy({
            by: ['tier'],
            where: { affiliateId },
            _sum: {
                commissionAmount: true,
            },
            _count: true,
        });

        return {
            tier1: {
                total: Number(stats.find((s) => s.tier === 1)?._sum.commissionAmount || 0),
                count: stats.find((s) => s.tier === 1)?._count || 0,
            },
            tier2: {
                total: Number(stats.find((s) => s.tier === 2)?._sum.commissionAmount || 0),
                count: stats.find((s) => s.tier === 2)?._count || 0,
            },
        };
    }
}
