import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/supabase_service.dart';

class UploadVideoScreen extends StatefulWidget {
  final String? videoPath;

  const UploadVideoScreen({
    Key? key,
    this.videoPath,
  }) : super(key: key);

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB39129);
  static const Color backgroundLight = Color(0xFFF6F7FB);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardAlt = Color(0xFFF1F4F9);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF667085);
  static const Color borderLight = Color(0xFFE4E7EC);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _hashtagController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final SupabaseService _supabaseService = SupabaseService();

  bool _affiliateLinkEnabled = true;
  bool _isPosting = false;
  String? _selectedVideoPath;
  String? _postErrorMessage;
  String _selectedGoal = 'Học ngay (Booking giáo viên)';
  String _selectedTeacher = 'Cô Linh - 4.9*';

  final List<String> _hashtagSuggestions = [
    '#luyenngon',
    '#cover',
    '#88phim',
    '#xpiano',
    '#beginner',
    '#piano',
  ];

  @override
  void initState() {
    super.initState();
    _selectedVideoPath = widget.videoPath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _hashtagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildVideoPreview().animate().fadeIn(duration: 400.ms),
                        const SizedBox(height: 28),
                        _buildTitleInput().animate().fadeIn(delay: 100.ms),
                        const SizedBox(height: 24),
                        _buildHashtagInput().animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 28),
                        _buildSettingsSection().animate().fadeIn(delay: 300.ms),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildFooter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: cardLight,
        border: Border(
          bottom: BorderSide(color: borderLight, width: 1),
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
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: textDark,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Đăng tải video',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
          ),
          GestureDetector(
            onTap: _handleSaveDraft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: cardAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderLight),
              ),
              child: Text(
                'Lưu nháp',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: darkGold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: cardAlt,
                child: _buildVideoPreviewContent(),
              ),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: primaryGold.withOpacity(0.92),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryGold.withOpacity(0.35),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.black,
                    size: 40,
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '9:16',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: GestureDetector(
                  onTap: _pickVideoFromGallery,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedVideoPath == null
                          ? 'Chọn MP4'
                          : 'Đổi video',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPreviewContent() {
    if (_selectedVideoPath == null || _selectedVideoPath!.trim().isEmpty) {
      return _buildPlaceholder();
    }

    final normalizedPath = _selectedVideoPath!.replaceAll('\\', '/');
    final fileName = normalizedPath.split('/').last;

    return Container(
      color: const Color(0xFF0B0F14),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.movie_creation_outlined,
                size: 62,
                color: Color(0xFFD4AF37),
              ),
              const SizedBox(height: 12),
              Text(
                fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'MP4 ready to upload',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_outlined, size: 64, color: Colors.grey[500]),
          const SizedBox(height: 16),
          Text(
            'Xem trước video',
            style: GoogleFonts.inter(fontSize: 14, color: textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiêu đề',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderLight),
          ),
          child: TextField(
            controller: _titleController,
            style: GoogleFonts.inter(fontSize: 15, color: textDark),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Nhập tiêu đề video...',
              hintStyle: GoogleFonts.inter(fontSize: 15, color: textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHashtagInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hashtag',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderLight),
          ),
          child: TextField(
            controller: _hashtagController,
            style: GoogleFonts.inter(fontSize: 15, color: textDark),
            decoration: InputDecoration(
              hintText: '#luyenngon #beginner...',
              hintStyle: GoogleFonts.inter(fontSize: 15, color: textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _hashtagSuggestions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                    right: index < _hashtagSuggestions.length - 1 ? 10 : 0),
                child: _buildHashtagChip(_hashtagSuggestions[index], index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHashtagChip(String hashtag, int index) {
    return GestureDetector(
      onTap: () {
        final current = _hashtagController.text.trim();
        if (current.isEmpty) {
          _hashtagController.text = hashtag;
        } else if (!current.contains(hashtag)) {
          _hashtagController.text = '$current $hashtag';
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: primaryGold.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryGold.withOpacity(0.35), width: 1.2),
        ),
        child: Text(
          hashtag,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: darkGold,
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(
          begin: 0.2,
          duration: 400.ms,
          delay: (index * 50).ms,
        );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cài đặt',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 20),
          _buildDropdown(
            label: 'Gắn mục tiêu',
            value: _selectedGoal,
            onTap: _showGoalPicker,
          ),
          const SizedBox(height: 20),
          _buildDropdown(
            label: 'Giáo viên liên quan',
            value: _selectedTeacher,
            onTap: _showTeacherPicker,
          ),
          const SizedBox(height: 24),
          const Divider(color: borderLight, height: 1),
          const SizedBox(height: 24),
          _buildAffiliateToggle(),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textMuted,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cardAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textDark,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down,
                    color: darkGold, size: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAffiliateToggle() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đính kèm link giới thiệu',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Link sẽ gắn vào video để ghi nhận thưởng minh bạch.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            setState(() {
              _affiliateLinkEnabled = !_affiliateLinkEnabled;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 32,
            decoration: BoxDecoration(
              color: _affiliateLinkEnabled ? primaryGold : Colors.grey[350],
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: _affiliateLinkEnabled
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: cardLight,
        border: const Border(top: BorderSide(color: borderLight, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_postErrorMessage != null) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withOpacity(0.25)),
              ),
              child: Text(
                _postErrorMessage!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.red[700],
                ),
              ),
            ),
          ],
          GestureDetector(
            onTap: _isPosting ? null : _handlePost,
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
              child: Text(
                _isPosting ? 'Đang đăng...' : 'Đăng',
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
          Text(
            'Bằng việc đăng, bạn đồng ý tiêu chuẩn cộng đồng.',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleSaveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã lưu nháp', style: GoogleFonts.inter()),
        backgroundColor: darkGold,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handlePost() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập tiêu đề', style: GoogleFonts.inter()),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedVideoPath == null || _selectedVideoPath!.trim().isEmpty) {
      await _pickVideoFromGallery();
      if (_selectedVideoPath == null || _selectedVideoPath!.trim().isEmpty) {
        return;
      }
    }

    setState(() {
      _isPosting = true;
      _postErrorMessage = null;
    });

    try {
      final userId = _supabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('Bạn cần đăng nhập trước khi đăng video');
      }

      final safeTitle = _titleController.text
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-|-$'), '');
      final fileNamePart = safeTitle.isEmpty ? 'video' : safeTitle;
      final destPath =
          'test/$userId/${DateTime.now().millisecondsSinceEpoch}_$fileNamePart.mp4';

      final mediaUrl = await _supabaseService.uploadVideoToStorage(
        filePath: _selectedVideoPath!,
        destPath: destPath,
      );

      await _supabaseService.createSocialFeedPost(
        caption: _titleController.text.trim(),
        mediaUrl: mediaUrl,
        mediaType: 'video',
        hashtags: _extractHashtags(_hashtagController.text),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Đăng video thành công!', style: GoogleFonts.inter()),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _postErrorMessage = _buildPostErrorMessage(e);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_postErrorMessage!, style: GoogleFonts.inter()),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  Future<void> _pickVideoFromGallery() async {
    try {
      final picked = await _picker.pickVideo(source: ImageSource.gallery);
      if (picked == null) return;

      final normalizedPath = picked.path.toLowerCase();
      if (!normalizedPath.endsWith('.mp4')) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Hiện tại chỉ hỗ trợ tệp .mp4', style: GoogleFonts.inter()),
            backgroundColor: Colors.orange[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        _selectedVideoPath = picked.path;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể chọn video: $e', style: GoogleFonts.inter()),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _buildPostErrorMessage(Object error) {
    final raw = error.toString();
    final lower = raw.toLowerCase();
    if (lower.contains('row-level security') ||
        lower.contains('unauthorized') ||
        lower.contains('statuscode:403')) {
      return 'Upload bị chặn bởi policy (RLS 403). '
          'Hãy chạy lại social_feed_video_upload_setup.sql và đăng nhập lại tài khoản.';
    }
    return 'Đăng video thất bại: $raw';
  }

  List<String> _extractHashtags(String raw) {
    return raw
        .split(RegExp(r'\s+'))
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .map((tag) => tag.replaceAll('#', ''))
        .map((tag) => tag.toLowerCase())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
  }

  void _showGoalPicker() {
    final goals = [
      'Học ngay (Booking giáo viên)',
      'Muốn đàn',
      'Xem để giải trí',
      'Không gắn mục tiêu',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Chọn mục tiêu',
        options: goals,
        selected: _selectedGoal,
        onSelected: (value) {
          setState(() {
            _selectedGoal = value;
          });
        },
      ),
    );
  }

  void _showTeacherPicker() {
    final teachers = [
      'Cô Linh - 4.9*',
      'Thầy Minh - 4.8*',
      'Cô Hồng - 4.7*',
      'Không chọn giáo viên',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPickerSheet(
        title: 'Chọn giáo viên',
        options: teachers,
        selected: _selectedTeacher,
        onSelected: (value) {
          setState(() {
            _selectedTeacher = value;
          });
        },
      ),
    );
  }

  Widget _buildPickerSheet({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 20),
          ...options.map((option) {
            final isSelected = option == selected;
            return GestureDetector(
              onTap: () {
                onSelected(option);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSelected ? primaryGold.withOpacity(0.12) : cardAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? primaryGold : borderLight,
                    width: 1,
                  ),
                ),
                child: Text(
                  option,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? darkGold : textDark,
                  ),
                ),
              ),
            );
          }).toList(),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
