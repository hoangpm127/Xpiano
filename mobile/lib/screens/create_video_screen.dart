import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'upload_video_screen.dart';

class CreateVideoScreen extends StatefulWidget {
  const CreateVideoScreen({Key? key}) : super(key: key);

  @override
  State<CreateVideoScreen> createState() => _CreateVideoScreenState();
}

class _CreateVideoScreenState extends State<CreateVideoScreen> {
  // Spiano Dark Luxury Colors
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB39129);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Title
                    Text(
                      'Tạo video mới',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(
                      begin: -0.2,
                      duration: 400.ms,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      'Chia sẻ video dạy piano của bạn',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.grey[500],
                      ),
                    ).animate().fadeIn(delay: 100.ms),
                    
                    const SizedBox(height: 48),
                    
                    // Main Options
                    _buildMainOption(
                      icon: Icons.videocam,
                      iconColor: Colors.red[400]!,
                      title: 'Quay video',
                      subtitle: 'Quay video ngay bằng camera',
                      onTap: () {
                        _handleRecordVideo();
                      },
                      delay: 200,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildMainOption(
                      icon: Icons.photo_library,
                      iconColor: Colors.blue[400]!,
                      title: 'Chọn từ thư viện',
                      subtitle: 'Tải video có sẵn lên',
                      onTap: () {
                        _handlePickFromGallery();
                      },
                      delay: 300,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildMainOption(
                      icon: Icons.music_note,
                      iconColor: primaryGold,
                      title: 'Tạo với nhạc nền',
                      subtitle: 'Thêm nhạc piano vào video',
                      onTap: () {
                        _handleCreateWithMusic();
                      },
                      delay: 400,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey[800],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'HOẶC',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 500.ms),
                    
                    const SizedBox(height: 40),
                    
                    // Templates Section
                    _buildTemplatesSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Close Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          
          const Expanded(child: SizedBox()),
          
          // Help Button
          GestureDetector(
            onTap: () {
              _showHelpDialog();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.help_outline,
                    color: primaryGold,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Trợ giúp',
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

  Widget _buildMainOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required int delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 32,
              ),
            ),
            
            const SizedBox(width: 20),
            
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[600],
              size: 18,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(
      begin: 0.3,
      duration: 400.ms,
      delay: delay.ms,
    );
  }

  Widget _buildTemplatesSection() {
    final templates = [
      {
        'title': 'Bài học 5 phút',
        'icon': '⏱️',
        'color': Colors.purple[400],
      },
      {
        'title': 'Cover ngắn',
        'icon': '🎵',
        'color': Colors.pink[400],
      },
      {
        'title': 'Tips & Tricks',
        'icon': '💡',
        'color': Colors.orange[400],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Templates phổ biến',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ).animate().fadeIn(delay: 600.ms),
        
        const SizedBox(height: 20),
        
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: templates.asMap().entries.map((entry) {
            final index = entry.key;
            final template = entry.value;
            
            return GestureDetector(
              onTap: () {
                _handleTemplateSelected(template['title'] as String);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: (template['color'] as Color).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (template['color'] as Color).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      template['icon'] as String,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      template['title'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (700 + index * 100).ms).scale(
              begin: const Offset(0.8, 0.8),
              duration: 400.ms,
              delay: (700 + index * 100).ms,
            );
          }).toList(),
        ),
      ],
    );
  }

  void _handleRecordVideo() {
    // TODO: Open camera plugin to record video
    // For now, navigate directly to upload screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UploadVideoScreen(
          videoPath: null, // Will be set after camera recording
        ),
      ),
    );
  }

  void _handlePickFromGallery() {
    // TODO: Open image_picker to select video from gallery
    // For now, navigate directly to upload screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UploadVideoScreen(
          videoPath: null, // Will be set after gallery selection
        ),
      ),
    );
  }

  void _handleCreateWithMusic() {
    // TODO: Open music library screen
    // For now, navigate directly to upload screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UploadVideoScreen(
          videoPath: null, // Will be set after music selection
        ),
      ),
    );
  }

  void _handleTemplateSelected(String templateName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sử dụng template: $templateName',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: Colors.purple[400],
        behavior: SnackBarBehavior.floating,
      ),
    );
    // TODO: Open template editor
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: primaryGold),
            const SizedBox(width: 12),
            Text(
              'Mẹo tạo video',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem('📱', 'Quay video dọc (9:16) để hiển thị tốt nhất'),
            const SizedBox(height: 12),
            _buildHelpItem('⏱️', 'Video ngắn (15-60s) có tương tác cao hơn'),
            const SizedBox(height: 12),
            _buildHelpItem('🎹', 'Hiển thị rõ tay và phím đàn khi dạy'),
            const SizedBox(height: 12),
            _buildHelpItem('💡', 'Ánh sáng tốt giúp video chuyên nghiệp hơn'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đã hiểu',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[400],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
