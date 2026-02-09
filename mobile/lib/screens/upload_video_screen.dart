import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
  // Spiano Dark Luxury Colors
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB39129);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color cardDarker = Color(0xFF2E2E2E);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _hashtagController = TextEditingController();
  
  bool _affiliateLinkEnabled = true;
  String _selectedGoal = 'Học ngay (Booking giáo viên)';
  String _selectedTeacher = 'Cô Linh — 4.9⭐';

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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(child: _buildHeader()),
                
                // Content
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video Preview
                        _buildVideoPreview().animate().fadeIn(duration: 400.ms),
                        
                        const SizedBox(height: 32),
                        
                        // Title Input
                        _buildTitleInput().animate().fadeIn(delay: 100.ms),
                        
                        const SizedBox(height: 24),
                        
                        // Hashtag Input
                        _buildHashtagInput().animate().fadeIn(delay: 200.ms),
                        
                        const SizedBox(height: 32),
                        
                        // Settings Section
                        _buildSettingsSection().animate().fadeIn(delay: 300.ms),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Footer
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildFooter(),
            ),
          ],
        ),
      ),
    );
  }

  // Header
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
          // Back Button
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
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Text(
              'Upload video',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          
          // Save Draft Button
          GestureDetector(
            onTap: () {
              _handleSaveDraft();
            },
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
              child: Text(
                'Lưu nháp',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryGold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Video Preview
  Widget _buildVideoPreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryGold.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail (placeholder)
              Container(
                color: cardDarker,
                child: widget.videoPath != null
                    ? Image.network(
                        'https://picsum.photos/800/450?random=piano',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                      )
                    : _buildPlaceholder(),
              ),
              
              // Play Overlay
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: primaryGold.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryGold.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
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
              
              // Duration Badge
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
          Icon(
            Icons.videocam_outlined,
            size: 64,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            'Video preview',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Title Input
  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiêu đề',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _titleController,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white,
            ),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Nhập tiêu đề video...',
              hintStyle: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.grey[600],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  // Hashtag Input
  Widget _buildHashtagInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hashtag',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _hashtagController,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: '#luyenngon #beginner...',
              hintStyle: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.grey[600],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Suggestion Chips
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _hashtagSuggestions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < _hashtagSuggestions.length - 1 ? 10 : 0,
                ),
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
        final current = _hashtagController.text;
        if (current.isEmpty) {
          _hashtagController.text = hashtag;
        } else if (!current.contains(hashtag)) {
          _hashtagController.text = '$current $hashtag';
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryGold,
            width: 1.5,
          ),
        ),
        child: Text(
          hashtag,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(
      begin: 0.2,
      duration: 400.ms,
      delay: (index * 50).ms,
    );
  }

  // Settings Section
  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Cài đặt',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Goal Dropdown
          _buildDropdown(
            label: 'Gắn mục tiêu',
            value: _selectedGoal,
            onTap: () {
              _showGoalPicker();
            },
          ),
          
          const SizedBox(height: 20),
          
          // Teacher Dropdown
          _buildDropdown(
            label: 'Giáo viên liên quan',
            value: _selectedTeacher,
            onTap: () {
              _showTeacherPicker();
            },
          ),
          
          const SizedBox(height: 24),
          
          // Divider
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.05),
          ),
          
          const SizedBox(height: 24),
          
          // Affiliate Toggle
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
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cardDarker,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: primaryGold,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAffiliateToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Link sẽ gắn vào video để ghi nhận thưởng minh bạch',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[500],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Toggle Switch
            GestureDetector(
              onTap: () {
                setState(() {
                  _affiliateLinkEnabled = !_affiliateLinkEnabled;
                });
              },
              child: Container(
                width: 52,
                height: 32,
                decoration: BoxDecoration(
                  color: _affiliateLinkEnabled ? primaryGold : Colors.grey[700],
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
        ),
      ],
    );
  }

  // Footer
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundDark,
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Post Button
          GestureDetector(
            onTap: () {
              _handlePost();
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
          
          // Disclaimer
          Text(
            'Bằng việc đăng, bạn đồng ý tiêu chuẩn cộng đồng.',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Handlers
  void _handleSaveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã lưu nháp',
          style: GoogleFonts.inter(),
        ),
        backgroundColor: primaryGold,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handlePost() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng nhập tiêu đề video',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDarker,
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
                Icons.check_circle,
                color: primaryGold,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Video đang xử lý',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Video của bạn sẽ xuất hiện trên feed sau khi được xử lý (thường trong 5-10 phút)',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[400],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close upload screen
                Navigator.pop(context); // Close create screen
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

    // TODO: Upload to Supabase Storage
    // TODO: Insert record to database
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardDarker,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chọn mục tiêu',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ...goals.map((goal) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGoal = goal;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: _selectedGoal == goal
                        ? primaryGold.withOpacity(0.1)
                        : cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedGoal == goal
                          ? primaryGold
                          : Colors.white.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    goal,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _selectedGoal == goal ? primaryGold : Colors.white,
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

  void _showTeacherPicker() {
    final teachers = [
      'Cô Linh — 4.9⭐',
      'Thầy Minh — 4.8⭐',
      'Cô Hằng — 4.7⭐',
      'Không chọn giáo viên',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardDarker,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chọn giáo viên',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ...teachers.map((teacher) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTeacher = teacher;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: _selectedTeacher == teacher
                        ? primaryGold.withOpacity(0.1)
                        : cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedTeacher == teacher
                          ? primaryGold
                          : Colors.white.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    teacher,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color:
                          _selectedTeacher == teacher ? primaryGold : Colors.white,
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
}
