import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VideoPlayerDetailScreen extends StatelessWidget {
  final String videoTitle;
  final String duration;
  final String thumbnail;
  final String author;

  const VideoPlayerDetailScreen({
    super.key,
    required this.videoTitle,
    required this.duration,
    required this.thumbnail,
    required this.author,
  });

  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkBg = Color(0xFF0F1115);
  static const Color panelBg = Color(0xFF171A20);
  static const Color textMuted = Color(0xFF9AA3B2);

  @override
  Widget build(BuildContext context) {
    final comments = [
      'Bài này rất dễ hiểu, cảm ơn thầy/cô nhiều!',
      'Mình tập theo 3 ngày đã thấy tay trái ổn hơn.',
      'Phần pedal giải thích rõ ràng quá ạ.',
    ];

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildPlayer(context),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: panelBg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    Text(
                      videoTitle,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đăng bởi $author • $duration',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Mô tả: Video hướng dẫn luyện ngón cơ bản theo nhịp chậm. '
                      'Hãy tập 10-15 phút mỗi ngày để cải thiện độ đều và lực tay.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.45,
                        color: const Color(0xFFE6E8EC),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildAction(Icons.favorite_border, '1.2K'),
                        const SizedBox(width: 16),
                        _buildAction(Icons.chat_bubble_outline, '345'),
                        const SizedBox(width: 16),
                        _buildAction(Icons.share_outlined, 'Chia sẻ'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Bình luận',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...comments.map(_buildComment),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            thumbnail,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Colors.black26),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.35),
                  Colors.black.withOpacity(0.2),
                ],
              ),
            ),
          ),
          Positioned(
            left: 8,
            top: 8,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            ),
          ),
          Center(
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: primaryGold.withOpacity(0.92),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.play_arrow, color: Colors.black, size: 44),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.72),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                duration,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComment(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: primaryGold.withOpacity(0.3),
            child: const Icon(Icons.person, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFFE6E8EC),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
