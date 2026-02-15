import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'upload_video_screen.dart';

class CreateVideoScreen extends StatefulWidget {
  final VoidCallback? onVideoPosted;

  const CreateVideoScreen({
    super.key,
    this.onVideoPosted,
  });

  @override
  State<CreateVideoScreen> createState() => _CreateVideoScreenState();
}

class _CreateVideoScreenState extends State<CreateVideoScreen> {
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB39129);
  static const Color backgroundLight = Color(0xFFF6F7FB);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardAlt = Color(0xFFF1F4F9);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF667085);
  static const Color borderLight = Color(0xFFE4E7EC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: Stack(
        children: [
          _buildBackgroundDecor(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroCard(),
                        const SizedBox(height: 24),
                        _buildMainOption(
                          icon: Icons.videocam_rounded,
                          iconColor: Colors.red[400]!,
                          title: 'Quay video',
                          subtitle: 'Dùng camera để quay ngay',
                          badge: 'Nhanh',
                          onTap: _openUploadVideo,
                          delay: 120,
                        ),
                        const SizedBox(height: 14),
                        _buildMainOption(
                          icon: Icons.photo_library_rounded,
                          iconColor: Colors.blue[400]!,
                          title: 'Chọn từ thư viện',
                          subtitle: 'Đăng video có sẵn từ máy',
                          badge: 'Phổ biến',
                          onTap: _openUploadVideo,
                          delay: 200,
                        ),
                        const SizedBox(height: 14),
                        _buildMainOption(
                          icon: Icons.music_note_rounded,
                          iconColor: primaryGold,
                          title: 'Tạo với nhạc nền',
                          subtitle: 'Thêm nhạc piano vào video',
                          badge: 'Sáng tạo',
                          onTap: _openUploadVideo,
                          delay: 280,
                        ),
                        const SizedBox(height: 26),
                        Row(
                          children: [
                            const Expanded(child: Divider(color: borderLight)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'MẪU GỢI Ý',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                  color: textMuted,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider(color: borderLight)),
                          ],
                        ).animate().fadeIn(delay: 360.ms),
                        const SizedBox(height: 18),
                        _buildTemplateList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecor() {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -110,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [primaryGold.withOpacity(0.16), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.blue.withOpacity(0.08), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: cardLight,
        border: Border(
          bottom: BorderSide(color: borderLight),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cardAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderLight),
              ),
              child: const Icon(Icons.close, color: textDark, size: 20),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _showHelpDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: cardAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderLight),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.help_outline, color: darkGold, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Trợ giúp',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: darkGold,
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

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            primaryGold.withOpacity(0.14),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tạo video mới',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đăng video dạy piano với bố cục sáng và dễ đọc.',
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.45,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildMetric('9:16', 'Tỷ lệ đề xuất'),
              const SizedBox(width: 10),
              _buildMetric('15-60s', 'Độ dài tốt'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.12, duration: 400.ms);
  }

  Widget _buildMetric(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 12, color: textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badge,
    required VoidCallback onTap,
    required int delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cardAlt,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios, color: textMuted, size: 16),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: delay.ms)
        .slideX(begin: 0.22, duration: 350.ms, delay: delay.ms);
  }

  Widget _buildTemplateList() {
    final templates = [
      const _TemplateItem(
        title: 'Bài học 5 phút',
        subtitle: 'Hook nhanh + demo luyện ngón',
        color: Color(0xFF4F46E5),
        icon: Icons.timer_rounded,
      ),
      const _TemplateItem(
        title: 'Cover ngắn',
        subtitle: 'Mở bài + cao trào + outro',
        color: Color(0xFFEC4899),
        icon: Icons.music_video_rounded,
      ),
      const _TemplateItem(
        title: 'Tips & Tricks',
        subtitle: 'Một mẹo / một video',
        color: Color(0xFFF97316),
        icon: Icons.tips_and_updates_rounded,
      ),
    ];

    return Column(
      children: templates.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Padding(
          padding:
              EdgeInsets.only(bottom: index == templates.length - 1 ? 0 : 12),
          child: GestureDetector(
            onTap: _openUploadVideo,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.subtitle,
                          style:
                              GoogleFonts.inter(fontSize: 13, color: textMuted),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: textMuted),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (430 + index * 90).ms).slideY(
                begin: 0.18,
                duration: 320.ms,
                delay: (430 + index * 90).ms,
              ),
        );
      }).toList(),
    );
  }

  Future<void> _openUploadVideo() async {
    final posted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const UploadVideoScreen(videoPath: null),
      ),
    );
    if (posted == true) {
      widget.onVideoPosted?.call();
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: darkGold),
            const SizedBox(width: 10),
            Text(
              'Mẹo tạo video',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _HelpItem('Quay dọc 9:16 để hiển thị tốt hơn trên feed.'),
            SizedBox(height: 10),
            _HelpItem('Mở đầu 3 giây đầu cần rõ nội dung chính.'),
            SizedBox(height: 10),
            _HelpItem('Ánh sáng ổn định giúp video trong và nét hơn.'),
            SizedBox(height: 10),
            _HelpItem('Tiêu đề ngắn gọn + hashtag đúng chủ đề.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đã hiểu',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: darkGold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final String text;

  const _HelpItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Icon(Icons.check_circle,
              size: 14, color: _CreateVideoScreenState.darkGold),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _CreateVideoScreenState.textMuted,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _TemplateItem {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _TemplateItem({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });
}
