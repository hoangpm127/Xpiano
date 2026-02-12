import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/common/stub_helper.dart';

class TeacherWalletScreen extends StatefulWidget {
  const TeacherWalletScreen({Key? key}) : super(key: key);

  @override
  State<TeacherWalletScreen> createState() => _TeacherWalletScreenState();
}

class _TeacherWalletScreenState extends State<TeacherWalletScreen> {
  // Light Mode Palette
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB39129);
  static const Color backgroundDark = Color(0xFFF7F7F7);
  static const Color cardDark = Color(0xFFFFFFFF);
  static const Color cardDarker = Color(0xFFF1F1F1);
  static const Color borderLight = Color(0xFFE6E6E6);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B6B6B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header (Sticky)
            _buildHeader(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Main Balance Card
                    _buildBalanceCard(),

                    const SizedBox(height: 20),

                    // Monthly Stats Row
                    _buildMonthlyStats(),

                    const SizedBox(height: 24),

                    // Withdrawal Section
                    _buildWithdrawalSection(),

                    const SizedBox(height: 32),

                    // Recent Transactions
                    _buildTransactionHistory(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundDark,
        border: Border(
          bottom: BorderSide(
            color: borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderLight,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: textDark,
                size: 18,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Text(
              'Ví giáo viên',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
          ),

          // Export Button
          GestureDetector(
            onTap: _showExportSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryGold.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.file_download_outlined,
                    color: primaryGold,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Xuất',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryGold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Main Balance Card (Gold Glow)
  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryGold,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGold.withOpacity(0.15),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: primaryGold.withOpacity(0.1),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Text(
                  'Số dư khả dụng',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textMuted,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 12),

                // Balance Amount
                Text(
                  '12,800,000đ',
                  style: GoogleFonts.inter(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: primaryGold,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtext
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Có thể rút ngay',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4ADE80),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Decorative Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: primaryGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: primaryGold,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  // Monthly Stats Row
  Widget _buildMonthlyStats() {
    return Row(
      children: [
        // Card 1: This Month
        Expanded(
          child: _buildStatCard(
            label: 'Tháng này',
            value: '28.4tr',
            valueColor: textDark,
          ),
        ),

        const SizedBox(width: 12),

        // Card 2: Sessions
        Expanded(
          child: _buildStatCard(
            label: 'Số buổi',
            value: '86',
            valueColor: textDark,
          ),
        ),

        const SizedBox(width: 12),

        // Card 3: Rating
        Expanded(
          child: _buildStatCard(
            label: 'Đánh giá',
            value: '4.9',
            valueColor: primaryGold,
            icon: Icons.star,
            iconColor: primaryGold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color valueColor,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 4),
                Icon(
                  icon,
                  color: iconColor,
                  size: 16,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Withdrawal Section
  Widget _buildWithdrawalSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: primaryGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kỳ trả lương: Thứ 2 & Thứ 6 hàng tuần',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Withdraw Button
          GestureDetector(
            onTap: () {
              _showWithdrawDialog();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE6C86E),
                    Color(0xFFBF953F),
                    Color(0xFFE6C86E),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primaryGold.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_balance,
                    color: Colors.black,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Rút tiền về ngân hàng',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Helper Text
          Center(
            child: Text(
              'Tiền về tài khoản trong 1-2 ngày làm việc.',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Transaction History List
  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Giao dịch gần đây',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            TextButton(
              onPressed: () => openStub(
                context,
                'Lịch sử giao dịch',
                'Danh sách giao dịch đầy đủ sẽ được bổ sung ở bản tiếp theo.',
                icon: Icons.receipt_long_outlined,
              ),
              child: Text(
                'Xem tất cả',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryGold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Transaction Items
        _buildTransactionItem(
          icon: Icons.arrow_downward,
          iconColor: const Color(0xFF4ADE80),
          iconBg: const Color(0xFF4ADE80).withOpacity(0.1),
          title: 'Buổi dạy Offline - Ánh',
          subtitle: 'Hôm nay, 10:30',
          amount: '+ 350,000đ',
          amountColor: const Color(0xFF4ADE80),
        ),

        const SizedBox(height: 12),

        _buildTransactionItem(
          icon: Icons.arrow_downward,
          iconColor: const Color(0xFF4ADE80),
          iconBg: const Color(0xFF4ADE80).withOpacity(0.1),
          title: 'Buổi dạy Online - Minh',
          subtitle: 'Hôm qua',
          amount: '+ 250,000đ',
          amountColor: const Color(0xFF4ADE80),
        ),

        const SizedBox(height: 12),

        _buildTransactionItem(
          icon: Icons.remove_circle_outline,
          iconColor: textMuted,
          iconBg: Colors.grey.withOpacity(0.1),
          title: 'Phí nền tảng (10%)',
          subtitle: 'Đã trừ tự động',
          amount: '- 60,000đ',
          amountColor: textMuted,
        ),

        const SizedBox(height: 12),

        _buildTransactionItem(
          icon: Icons.arrow_upward,
          iconColor: Colors.orange,
          iconBg: Colors.orange.withOpacity(0.1),
          title: 'Rút về ngân hàng',
          subtitle: '5 ngày trước',
          amount: '- 5,000,000đ',
          amountColor: Colors.orange,
        ),

        const SizedBox(height: 12),

        _buildTransactionItem(
          icon: Icons.arrow_downward,
          iconColor: const Color(0xFF4ADE80),
          iconBg: const Color(0xFF4ADE80).withOpacity(0.1),
          title: 'Buổi dạy Online - Thu Hằng',
          subtitle: '6 ngày trước',
          amount: '+ 250,000đ',
          amountColor: const Color(0xFF4ADE80),
        ),
      ],
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 14),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: amountColor,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  void _showExportSheet() {
    const periods = ['Tuần này', 'Tháng này', 'Quý này', 'Tùy chỉnh ngày'];
    const formats = ['Excel (.xlsx)', 'PDF (.pdf)'];

    String selectedPeriod = periods[1];
    String selectedFormat = formats.first;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Xuất báo cáo doanh thu',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Khoảng thời gian',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: periods.map((period) {
                  final selected = selectedPeriod == period;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedPeriod = period),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? primaryGold.withOpacity(0.14)
                            : cardDarker,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected ? primaryGold : borderLight,
                        ),
                      ),
                      child: Text(
                        period,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? darkGold : textMuted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Text(
                'Định dạng file',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: formats.map((format) {
                  final selected = selectedFormat == format;
                  return GestureDetector(
                    onTap: () => setSheetState(() => selectedFormat = format),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? primaryGold.withOpacity(0.14)
                            : cardDarker,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: selected ? primaryGold : borderLight,
                        ),
                      ),
                      child: Text(
                        format,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? darkGold : textMuted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    String periodLabel = selectedPeriod;
                    if (selectedPeriod == 'Tùy chỉnh ngày') {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(DateTime.now().year - 1),
                        lastDate: DateTime.now(),
                        initialDateRange: DateTimeRange(
                          start:
                              DateTime.now().subtract(const Duration(days: 7)),
                          end: DateTime.now(),
                        ),
                      );
                      if (range == null) return;
                      periodLabel =
                          '${range.start.day.toString().padLeft(2, '0')}/${range.start.month.toString().padLeft(2, '0')} - ${range.end.day.toString().padLeft(2, '0')}/${range.end.month.toString().padLeft(2, '0')}';
                    }
                    if (!mounted) return;
                    Navigator.of(context).pop();
                    openStub(
                      context,
                      'Xuất báo cáo doanh thu',
                      'Tính năng xuất file $selectedFormat ($periodLabel) sẽ được kết nối backend ở bản tiếp theo.',
                      icon: Icons.file_download_outlined,
                    );
                  },
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: Text(
                    'Xuất ngay',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Withdraw Dialog
  void _showWithdrawDialog() {
    const banks = [
      'Vietcombank - ****39426',
      'MB Bank - ****18201',
      'Techcombank - ****55931',
    ];
    const availableBalance = 12800000;
    const withdrawFee = 5000;

    final amountController = TextEditingController();
    String selectedBank = banks.first;
    int selectedQuickIndex = -1;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          final amount = int.tryParse(
                amountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
              ) ??
              0;
          final received = amount <= withdrawFee ? 0 : amount - withdrawFee;

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: cardDarker,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Xác nhận rút tiền',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tài khoản nhận tiền',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedBank,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: cardDarker,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: borderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: borderLight),
                          ),
                        ),
                        items: banks
                            .map((bank) => DropdownMenuItem(
                                value: bank, child: Text(bank)))
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setSheetState(() => selectedBank = value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryGold.withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setSheetState(() {}),
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: primaryGold,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Nhập số tiền',
                            hintStyle: GoogleFonts.inter(
                                color: textMuted, fontSize: 16),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Text(
                        'đ',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAmountButton(
                        '1tr',
                        selected: selectedQuickIndex == 0,
                        onTap: () {
                          amountController.text = '1000000';
                          setSheetState(() => selectedQuickIndex = 0);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickAmountButton(
                        '5tr',
                        selected: selectedQuickIndex == 1,
                        onTap: () {
                          amountController.text = '5000000';
                          setSheetState(() => selectedQuickIndex = 1);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildQuickAmountButton(
                        'Tất cả',
                        selected: selectedQuickIndex == 2,
                        onTap: () {
                          amountController.text = '$availableBalance';
                          setSheetState(() => selectedQuickIndex = 2);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderLight),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Số dư khả dụng',
                              style: GoogleFonts.inter(color: textMuted)),
                          Text('${_formatCurrency(availableBalance)}đ',
                              style: GoogleFonts.inter(
                                  color: textDark,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Phí giao dịch',
                              style: GoogleFonts.inter(color: textMuted)),
                          Text('${_formatCurrency(withdrawFee)}đ',
                              style: GoogleFonts.inter(
                                  color: textDark,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Thực nhận',
                              style: GoogleFonts.inter(color: textMuted)),
                          Text('${_formatCurrency(received)}đ',
                              style: GoogleFonts.inter(
                                  color: primaryGold,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    if (amount < 100000) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Số tiền rút tối thiểu là 100,000đ.')),
                      );
                      return;
                    }
                    if (amount > availableBalance) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Số dư không đủ để thực hiện giao dịch.')),
                      );
                      return;
                    }
                    Navigator.pop(sheetContext);
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        backgroundColor: cardDark,
                        title: Text(
                          'Yêu cầu đã tạo',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700, color: textDark),
                        ),
                        content: Text(
                          'Đang xử lý rút ${_formatCurrency(amount)}đ về $selectedBank.\nSố tiền thực nhận: ${_formatCurrency(received)}đ',
                          style:
                              GoogleFonts.inter(color: textMuted, height: 1.5),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text(
                              'Đóng',
                              style: GoogleFonts.inter(
                                  color: primaryGold,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE6C86E),
                          Color(0xFFBF953F),
                          Color(0xFFE6C86E),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: primaryGold.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Xác nhận rút tiền',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                    height: MediaQuery.of(sheetContext).viewInsets.bottom + 8),
              ],
            ),
          );
        },
      ),
    ).whenComplete(amountController.dispose);
  }

  Widget _buildQuickAmountButton(
    String label, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? primaryGold.withOpacity(0.14) : cardDark,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? primaryGold : borderLight,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? darkGold : textDark,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _formatCurrency(int amount) {
    final source = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < source.length; i++) {
      final reverseIndex = source.length - i;
      buffer.write(source[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }
}
