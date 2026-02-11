import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

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

  bool _affiliateLinkEnabled = true;
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
                child: widget.videoPath != null
                    ? Image.network(
                        'https://picsum.photos/800/450?random=piano',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
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
            'Video preview',
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
          GestureDetector(
            onTap: _handlePost,
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
                'Đăng',
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

  void _handlePost() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Vui lòng nhập tiêu đề video', style: GoogleFonts.inter()),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              child: const Icon(Icons.check_circle, color: darkGold, size: 48),
            ),
            const SizedBox(height: 24),
            Text(
              'Video đang xử lý',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Video của bạn sẽ hiển thị trên feed sau khi được xử lý (thường 5-10 phút).',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: primaryGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Về trang chủ',
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

  void _showGoalPicker() {
    final goals = [
      'Học ngay (Booking giáo viên)',
      'Mượn đàn',
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
      'Cô Hằng - 4.7*',
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
