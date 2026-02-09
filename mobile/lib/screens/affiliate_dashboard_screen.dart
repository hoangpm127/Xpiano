import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AffiliateDashboardScreen extends StatefulWidget {
  const AffiliateDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AffiliateDashboardScreen> createState() =>
      _AffiliateDashboardScreenState();
}

class _AffiliateDashboardScreenState extends State<AffiliateDashboardScreen> {
  // Light Mode Colors
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB39129);
  static const Color backgroundLight =
      Color(0xFFFAFAFA); // Light gray background
  static const Color cardLight = Color(0xFFFFF9F0); // Cream/beige card
  static const Color cardDark =
      Color(0xFF1F1F1F); // Dark card/button for contrast
  static const Color textDark = Color(0xFF1A1A1A); // Dark text
  static const Color textGray = Color(0xFF666666); // Gray text

  int _selectedTabIndex = 0;
  String _selectedPeriod = 'Tháng này';

  final List<String> _periods = [
    'Tuần này',
    'Tháng này',
    'Quý này',
    'Tùy chỉnh ngày'
  ];

  final List<Map<String, String>> _downlineMembers = [
    {
      'name': 'Nguyễn Minh Anh',
      'joined': '05/02/2026',
      'status': 'Đang hoạt động',
      'revenue': '1,850,000đ',
    },
    {
      'name': 'Lê Hà My',
      'joined': '02/02/2026',
      'status': 'Đã mua gói',
      'revenue': '950,000đ',
    },
    {
      'name': 'Trần Tuấn Anh',
      'joined': '28/01/2026',
      'status': 'Mới đăng ký',
      'revenue': '0đ',
    },
  ];

  final List<Map<String, String>> _withdrawRecords = [
    {
      'date': '06/02/2026',
      'amount': '12,000,000đ',
      'status': 'Đang xử lý',
      'bank': 'Vietcombank ••••39426',
    },
    {
      'date': '30/01/2026',
      'amount': '8,500,000đ',
      'status': 'Hoàn tất',
      'bank': 'MB Bank ••••18201',
    },
    {
      'date': '20/01/2026',
      'amount': '15,000,000đ',
      'status': 'Hoàn tất',
      'bank': 'Techcombank ••••55931',
    },
  ];

  final List<Map<String, String>> _historyRecords = [
    {
      'id': '#AF-2406',
      'time': 'Hôm nay • 14:20',
      'event': 'Hoa hồng từ booking mới',
      'amount': '+350,000đ',
    },
    {
      'id': '#AF-2405',
      'time': 'Hôm nay • 10:15',
      'event': 'Hoa hồng từ mượn đàn',
      'amount': '+50,000đ',
    },
    {
      'id': '#AF-2398',
      'time': '03/02/2026 • 09:00',
      'event': 'Rút tiền về ngân hàng',
      'amount': '-8,500,000đ',
    },
  ];
  final List<Map<String, dynamic>> _recentTransactions = [
    {
      'id': '#BK-8F29A1',
      'time': 'Hôm nay • 14:20',
      'type': 'Học đàn (Booking)',
      'originalPrice': '3,500,000đ',
      'commission': '350,000đ',
      'status': 'T+1',
      'statusColor': Colors.orange,
    },
    {
      'id': '#BK-7A2B5C',
      'time': 'Hôm nay • 10:15',
      'type': 'Mượn đàn',
      'originalPrice': '500,000đ',
      'commission': '50,000đ',
      'status': 'T+1',
      'statusColor': Colors.orange,
    },
    {
      'id': '#BK-9D4E3F',
      'time': 'Hôm qua • 16:45',
      'type': 'Học đàn (Booking)',
      'originalPrice': '5,000,000đ',
      'commission': '500,000đ',
      'status': 'Đã duyệt',
      'statusColor': Colors.green,
    },
    {
      'id': '#BK-6C1A8E',
      'time': '2 ngày trước • 09:30',
      'type': 'Gói VIP',
      'originalPrice': '10,000,000đ',
      'commission': '1,000,000đ',
      'status': 'Đã thanh toán',
      'statusColor': primaryGold,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Performance Grid
                    _buildPerformanceGrid().animate().fadeIn(duration: 400.ms),

                    const SizedBox(height: 32),

                    // Navigation Tabs
                    _buildNavigationTabs().animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 24),

                    // Content based on selected tab
                    _buildTabContent(),
                  ],
                ),
              ),
            ),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black87,
                    size: 18,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Title
              Expanded(
                child: Text(
                  'Affiliate Dashboard',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
              ),

              // Period Filter
              GestureDetector(
                onTap: () {
                  _showPeriodPicker();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: primaryGold,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedPeriod,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryGold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: primaryGold,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            'Chỉ ghi nhận khi có giao dịch thật.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Row 1
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: 'Clicks',
                  value: '128,400',
                  change: '+8%',
                  isPositive: true,
                  delay: 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  label: 'Booking',
                  value: '3,240',
                  change: '+10%',
                  isPositive: true,
                  delay: 100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: 'GMV',
                  value: '8.5 tỷ',
                  change: '+12%',
                  isPositive: true,
                  delay: 200,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCommissionCard(delay: 300),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String change,
    required bool isPositive,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textGray,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPositive
                  ? Colors.green.withOpacity(0.15)
                  : Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  change,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(
          begin: 0.2,
          duration: 400.ms,
          delay: delay.ms,
        );
  }

  Widget _buildCommissionCard({required int delay}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE6C86E),
            Color(0xFFBF953F),
            Color(0xFFE6C86E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryGold.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoa hồng',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '520,000,000đ',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_upward,
                  size: 12,
                  color: Colors.black.withOpacity(0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  '+9%',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay.ms)
        .slideY(
          begin: 0.2,
          duration: 400.ms,
          delay: delay.ms,
        )
        .shimmer(
          duration: 2000.ms,
          delay: 500.ms,
        );
  }

  Widget _buildNavigationTabs() {
    final tabs = ['Tổng quan', 'Tuyến dưới', 'Rút tiền', 'Lịch sử'];

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isActive = _selectedTabIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isActive
                      ? primaryGold.withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isActive
                      ? Border.all(color: primaryGold, width: 1.5)
                      : null,
                ),
                child: Center(
                  child: Text(
                    tab,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? primaryGold : textGray,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildDownlineTab();
      case 2:
        return _buildWithdrawTab();
      case 3:
        return _buildHistoryTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giao dịch gần đây',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 16),

          // Transaction List
          ...(_recentTransactions.asMap().entries.map((entry) {
            final index = entry.key;
            final transaction = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTransactionCard(transaction, index),
            );
          }).toList()),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction, int index) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Giao dịch ${transaction['id']}',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              Text(
                transaction['time'],
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Type Badge
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                transaction['type'],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textGray,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Values Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left: Prices
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['originalPrice'],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction['commission'],
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: primaryGold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),

              // Right: Status Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: transaction['statusColor'],
                    width: 1.5,
                  ),
                ),
                child: Text(
                  transaction['status'],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: transaction['statusColor'],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (100 + index * 50).ms).slideX(
          begin: 0.2,
          duration: 400.ms,
          delay: (100 + index * 50).ms,
        );
  }

  Widget _buildDownlineTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh sách tuyến dưới',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildDownlineStatRow('Tổng user giới thiệu', '1,240'),
                const SizedBox(height: 12),
                _buildDownlineStatRow('Đang hoạt động', '856'),
                const SizedBox(height: 12),
                _buildDownlineStatRow('Đã chuyển đổi', '384'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ..._downlineMembers.asMap().entries.map((entry) {
            final index = entry.key;
            final member = entry.value;
            return Container(
              margin: EdgeInsets.only(
                  bottom: index == _downlineMembers.length - 1 ? 0 : 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: primaryGold.withOpacity(0.18),
                    child: Icon(Icons.person, color: primaryGold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member['name']!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tham gia: ${member['joined']}',
                          style:
                              GoogleFonts.inter(fontSize: 12, color: textGray),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          member['status']!,
                          style:
                              GoogleFonts.inter(fontSize: 12, color: textGray),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    member['revenue']!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: primaryGold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildDownlineStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: textGray,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildWithdrawTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rút hoa hồng',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Số dư khả dụng',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '520,000,000đ',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: primaryGold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 18),
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
                'Rút tiền về ngân hàng',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: primaryGold, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Lưu ý rút tiền',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoItem('• Rút tối thiểu: 1,000,000đ'),
                _buildInfoItem('• Thời gian xử lý: 1-3 ngày làm việc'),
                _buildInfoItem('• Phí rút: Miễn phí'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Lịch sử rút hoa hồng',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 10),
          ..._withdrawRecords.map((record) {
            final statusColor =
                record['status'] == 'Hoàn tất' ? Colors.green : Colors.orange;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.account_balance,
                        color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record['amount']!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${record['date']} • ${record['bank']}',
                          style:
                              GoogleFonts.inter(fontSize: 12, color: textGray),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      record['status']!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: textGray,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lịch sử giao dịch',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 10),
          ..._historyRecords.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isPositive = item['amount']!.startsWith('+');
            return Container(
              margin: EdgeInsets.only(
                  bottom: index == _historyRecords.length - 1 ? 0 : 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.withOpacity(0.12)
                          : Colors.orange.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                      color: isPositive ? Colors.green : Colors.orange,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item['id']} • ${item['time']}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: textGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['event']!,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    item['amount']!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isPositive ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Create Share Link Button
          GestureDetector(
            onTap: () {
              _handleCreateShareLink();
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
                'Tạo link chia sẻ',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Policy Link
          GestureDetector(
            onTap: () {
              _showCommissionPolicy();
            },
            child: Text(
              'Chi tiết chính sách hoa hồng',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: primaryGold,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Handlers
  void _showPeriodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chọn khoảng thời gian',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 20),
            ..._periods.map((period) {
              return GestureDetector(
                onTap: () async {
                  if (period == 'Tùy chỉnh ngày') {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(DateTime.now().year - 1),
                      lastDate: DateTime.now(),
                      initialDateRange: DateTimeRange(
                        start: DateTime.now().subtract(const Duration(days: 7)),
                        end: DateTime.now(),
                      ),
                    );
                    if (range == null) return;
                    if (!mounted) return;
                    setState(() {
                      _selectedPeriod =
                          '${range.start.day.toString().padLeft(2, '0')}/${range.start.month.toString().padLeft(2, '0')} - ${range.end.day.toString().padLeft(2, '0')}/${range.end.month.toString().padLeft(2, '0')}';
                    });
                    Navigator.pop(sheetContext);
                    return;
                  }

                  setState(() {
                    _selectedPeriod = period;
                  });
                  Navigator.pop(sheetContext);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: _selectedPeriod == period
                        ? primaryGold.withOpacity(0.1)
                        : cardLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedPeriod == period
                          ? primaryGold
                          : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    period,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _selectedPeriod == period ? primaryGold : textDark,
                    ),
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  void _handleCreateShareLink() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primaryGold.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.link,
                color: primaryGold,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Link chia sẻ của bạn',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Text(
                'xpiano.vn/ref/USER8F29A1',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: primaryGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đã sao chép link',
                            style: GoogleFonts.inter(),
                          ),
                          backgroundColor: primaryGold,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: primaryGold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Sao chép',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implement share functionality
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: cardDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryGold, width: 1),
                      ),
                      child: Text(
                        'Chia sẻ',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: primaryGold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCommissionPolicy() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chính sách hoa hồng',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPolicySection(
                      '1. Tỷ lệ hoa hồng',
                      '• Booking giáo viên: 10% GMV\n• Mượn đàn: 10% GMV\n• Gói VIP: 10% GMV',
                    ),
                    const SizedBox(height: 20),
                    _buildPolicySection(
                      '2. Thời gian thanh toán',
                      '• T+1: Đơn hàng được xác nhận trong 1 ngày\n• T+7: Sau khi hoàn thành dịch vụ\n• Hoa hồng được duyệt sau 7 ngày',
                    ),
                    const SizedBox(height: 20),
                    _buildPolicySection(
                      '3. Điều kiện rút tiền',
                      '• Số dư tối thiểu: 1,000,000đ\n• Miễn phí rút tiền\n• Xử lý trong 1-3 ngày làm việc',
                    ),
                    const SizedBox(height: 20),
                    _buildPolicySection(
                      '4. Quy tắc',
                      '• Link chỉ được ghi nhận cho người dùng mới\n• Hoa hồng chỉ tính khi có giao dịch thật\n• Vi phạm sẽ bị khóa tài khoản',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: primaryGold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: textGray,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance,
              color: primaryGold,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Rút tiền về ngân hàng',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Chức năng này sẽ được bổ sung sau. Vui lòng liên kết tài khoản ngân hàng trước.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textGray,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: primaryGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Đã hiểu',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
