import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { TransactionType, TransactionDirection, TransactionStatus } from '@prisma/client';

interface CreditMetadata {
    type: 'commission' | 'refund' | 'bonus';
    referenceType: string;
    referenceId: string;
    description: string;
}

interface DebitMetadata {
    type: 'withdrawal';
    description: string;
}

@Injectable()
export class WalletService {
    constructor(private readonly prisma: PrismaService) { }

    /**
     * Credit money to wallet (add balance)
     * This method is used within transactions
     */
    async credit(
        tx: any, // Prisma transaction client
        userId: string,
        amount: number,
        meta: CreditMetadata,
    ) {
        // Get current wallet
        const wallet = await tx.wallet.findUnique({
            where: { userId },
        });

        if (!wallet) {
            throw new NotFoundException('Wallet not found');
        }

        const balanceBefore = Number(wallet.balance);
        const balanceAfter = balanceBefore + amount;

        // Update wallet balance
        await tx.wallet.update({
            where: { id: wallet.id },
            data: {
                balance: balanceAfter,
                totalEarned: Number(wallet.totalEarned) + amount,
            },
        });

        // Create transaction record
        const transaction = await tx.walletTransaction.create({
            data: {
                walletId: wallet.id,
                type: meta.type as TransactionType,
                direction: TransactionDirection.credit,
                amount,
                balanceBefore,
                balanceAfter,
                referenceType: meta.referenceType,
                referenceId: meta.referenceId,
                description: meta.description,
                status: TransactionStatus.completed,
            },
        });

        return transaction;
    }

    /**
     * Debit money from wallet (withdraw)
     */
    async debit(userId: string, amount: number, meta: DebitMetadata) {
        return this.prisma.executeTransaction(async (tx) => {
            const wallet = await tx.wallet.findUnique({
                where: { userId },
            });

            if (!wallet) {
                throw new NotFoundException('Wallet not found');
            }

            const currentBalance = Number(wallet.balance);

            if (currentBalance < amount) {
                throw new BadRequestException('Số dư không đủ');
            }

            const balanceBefore = currentBalance;
            const balanceAfter = currentBalance - amount;

            // Update wallet
            await tx.wallet.update({
                where: { id: wallet.id },
                data: {
                    balance: balanceAfter,
                    totalWithdrawn: Number(wallet.totalWithdrawn) + amount,
                },
            });

            // Create transaction record
            return tx.walletTransaction.create({
                data: {
                    walletId: wallet.id,
                    type: TransactionType.withdrawal,
                    direction: TransactionDirection.debit,
                    amount,
                    balanceBefore,
                    balanceAfter,
                    description: meta.description,
                    status: TransactionStatus.pending, // Will be completed after bank transfer
                },
            });
        });
    }

    /**
     * Get wallet by user ID
     */
    async getWallet(userId: string) {
        const wallet = await this.prisma.wallet.findUnique({
            where: { userId },
        });

        if (!wallet) {
            throw new NotFoundException('Wallet not found');
        }

        return {
            id: wallet.id,
            balance: Number(wallet.balance),
            pendingBalance: Number(wallet.pendingBalance),
            totalEarned: Number(wallet.totalEarned),
            totalWithdrawn: Number(wallet.totalWithdrawn),
            currency: wallet.currency,
        };
    }

    /**
     * Get wallet transactions
     */
    async getTransactions(userId: string, limit = 20) {
        const wallet = await this.prisma.wallet.findUnique({
            where: { userId },
        });

        if (!wallet) {
            throw new NotFoundException('Wallet not found');
        }

        const transactions = await this.prisma.walletTransaction.findMany({
            where: { walletId: wallet.id },
            orderBy: { createdAt: 'desc' },
            take: limit,
        });

        return transactions.map((tx) => ({
            id: tx.id,
            type: tx.type,
            direction: tx.direction,
            amount: Number(tx.amount),
            balanceBefore: Number(tx.balanceBefore),
            balanceAfter: Number(tx.balanceAfter),
            description: tx.description,
            status: tx.status,
            createdAt: tx.createdAt,
        }));
    }
}
