import { Controller, Get, Post, Body, UseGuards, BadRequestException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { WalletService } from './wallet.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { User } from '@prisma/client';

class WithdrawDto {
    amount: number;
    bankAccount: string;
    bankName: string;
}

@ApiTags('wallet')
@Controller('wallet')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class WalletController {
    constructor(private readonly walletService: WalletService) { }

    @Get()
    @ApiOperation({ summary: 'Lấy thông tin ví của tôi' })
    async getMyWallet(@CurrentUser() user: User) {
        return this.walletService.getWallet(user.id);
    }

    @Get('transactions')
    @ApiOperation({ summary: 'Lấy lịch sử giao dịch ví' })
    async getTransactions(@CurrentUser() user: User) {
        return this.walletService.getTransactions(user.id);
    }

    @Post('withdraw')
    @ApiOperation({ summary: 'Yêu cầu rút tiền' })
    async withdraw(@CurrentUser() user: User, @Body() dto: WithdrawDto) {
        const MIN_WITHDRAWAL = 100000; // 100k VND

        if (dto.amount < MIN_WITHDRAWAL) {
            throw new BadRequestException(
                `Số tiền rút tối thiểu là ${MIN_WITHDRAWAL.toLocaleString()}đ`,
            );
        }

        const transaction = await this.walletService.debit(user.id, dto.amount, {
            type: 'withdrawal',
            description: `Rút về ${dto.bankName} - ${dto.bankAccount}`,
        });

        // TODO: Queue bank transfer job

        return {
            message:
                'Yêu cầu rút tiền đã được ghi nhận. Tiền sẽ về tài khoản trong 1-3 ngày làm việc.',
            transactionId: transaction.id,
        };
    }
}
