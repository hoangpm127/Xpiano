import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsListScreen extends StatelessWidget {
  const NotificationsListScreen({super.key});

  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color backgroundLight = Color(0xFFF7F7F7);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE6E6E6);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B6B6B);

  @override
  Widget build(BuildContext context) {
    final items = <_NotificationItem>[
      _NotificationItem(
        icon: Icons.calendar_month,
        title: 'Có booking mới',
        message: 'Học viên Minh Anh đã đặt buổi học 1-1 lúc 19:30 tối nay.',
        time: '5 phút trước',
        iconBg: Color(0xFFEFF6FF),
        iconColor: Color(0xFF2563EB),
      ),
      _NotificationItem(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Tiền đã về ví',
        message: '250,000đ từ buổi học Online đã được cộng vào ví giáo viên.',
        time: '32 phút trước',
        iconBg: Color(0xFFF0FDF4),
        iconColor: Color(0xFF16A34A),
      ),
      _NotificationItem(
        icon: Icons.assignment_turned_in_outlined,
        title: 'Học viên nộp bài',
        message: 'Thu Hằng vừa nộp video bài tập tuần này.',
        time: '1 giờ trước',
        iconBg: Color(0xFFFFF7ED),
        iconColor: Color(0xFFEA580C),
      ),
      _NotificationItem(
        icon: Icons.notifications_active_outlined,
        title: 'Nhắc lịch dạy',
        message: 'Bạn có buổi học với Hải Đăng sau 30 phút.',
        time: 'Hôm nay 15:00',
        iconBg: Color(0xFFFEFCE8),
        iconColor: Color(0xFFCA8A04),
      ),
    ];

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: cardLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Danh sách thông báo',
          style: GoogleFonts.inter(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: cardLight,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _FilterChip(label: 'Tất cả', active: true),
                _FilterChip(label: 'Booking'),
                _FilterChip(label: 'Ví'),
                _FilterChip(label: 'Bài tập'),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderLight),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: item.iconBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, color: item.iconColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: textDark,
                                    ),
                                  ),
                                ),
                                Text(
                                  item.time,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.message,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                height: 1.4,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã đánh dấu tất cả là đã đọc')),
          );
        },
        backgroundColor: primaryGold,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.done_all),
        label: Text(
          'Đánh dấu đã đọc',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final Color iconBg;
  final Color iconColor;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.iconBg,
    required this.iconColor,
  });
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;

  const _FilterChip({
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color:
            active ? const Color(0xFFD4AF37).withOpacity(0.15) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? const Color(0xFFD4AF37) : const Color(0xFFE6E6E6),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: active ? const Color(0xFFB39129) : const Color(0xFF6B6B6B),
        ),
      ),
    );
  }
}
