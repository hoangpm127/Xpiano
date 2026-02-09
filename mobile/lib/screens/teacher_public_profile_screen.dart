import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TeacherPublicProfileScreen extends StatefulWidget {
  final String? teacherName;
  final String? teacherAvatar;
  
  const TeacherPublicProfileScreen({
    Key? key,
    this.teacherName,
    this.teacherAvatar,
  }) : super(key: key);

  @override
  State<TeacherPublicProfileScreen> createState() => _TeacherPublicProfileScreenState();
}

class _TeacherPublicProfileScreenState extends State<TeacherPublicProfileScreen> {
  // Spiano Dark Luxury Colors
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB39129);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color cardDarker = Color(0xFF2E2E2E);

  int _selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();

  // Mock data
  final String _likes = '128K';
  final String _followers = '2.4K';
  final String _bio = 'Chia sẻ hành trình học piano từ con số 0.\n🎹 Beginner | Luyện ngón | Cover';

  final List<VideoItem> _videos = [
    VideoItem(
      thumbnail: 'https://picsum.photos/400/600?random=1',
      title: 'Luyện ngón 5 phút',
      duration: '0:32',
    ),
    VideoItem(
      thumbnail: 'https://picsum.photos/400/600?random=2',
      title: 'Cover Ballad',
      duration: '1:15',
    ),
    VideoItem(
      thumbnail: 'https://picsum.photos/400/600?random=3',
      title: 'Bài 1 cho người mới',
      duration: '10:00',
    ),
    VideoItem(
      thumbnail: 'https://picsum.photos/400/600?random=4',
      title: '88 phím vs 61 phím',
      duration: '0:32',
    ),
    VideoItem(
      thumbnail: 'https://picsum.photos/400/600?random=5',
      title: 'Kỹ thuật pedal cơ bản',
      duration: '2:45',
    ),
    VideoItem(
      thumbnail: 'https://picsum.photos/400/600?random=6',
      title: 'Chơi hợp âm đầu tiên',
      duration: '3:20',
    ),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.teacherName ?? 'Linh Nguyễn';
    final displayAvatar = widget.teacherAvatar;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Profile Header
              SliverToBoxAdapter(
                child: _buildProfileHeader(displayName, displayAvatar),
              ),
              
              // Content Tabs (Sticky)
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  child: _buildContentTabs(),
                ),
              ),
              
              // Tab Content
              SliverToBoxAdapter(
                child: _buildTabContent(),
              ),
            ],
          ),
          
          // Back Button (Top-left)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: _buildBackButton(),
          ),
          
          // Floating Action Button
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: _buildFAB(),
            ),
          ),
        ],
      ),
    );
  }

  // Back Button
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 18,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  // Profile Header
  Widget _buildProfileHeader(String name, String? avatar) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 70,
        20,
        32,
      ),
      child: Column(
        children: [
          // Avatar with Gold Ring
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryGold,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryGold.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: avatar != null && avatar.isNotEmpty
                  ? Image.network(
                      avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar();
                      },
                    )
                  : _buildDefaultAvatar(),
            ),
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            duration: 500.ms,
            curve: Curves.easeOutBack,
          ),
          
          const SizedBox(height: 20),
          
          // Name
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ).animate().fadeIn(delay: 100.ms),
          
          const SizedBox(height: 12),
          
          // Verification Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryGold.withOpacity(0.2),
                  primaryGold.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryGold,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified,
                  color: primaryGold,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Giáo viên đã xác thực',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryGold,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(
            begin: 0.2,
            duration: 400.ms,
          ),
          
          const SizedBox(height: 20),
          
          // Bio
          Text(
            _bio,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[400],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          
          const SizedBox(height: 24),
          
          // Social Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem(_likes, 'lượt thích'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  shape: BoxShape.circle,
                ),
              ),
              _buildStatItem(_followers, 'người theo dõi'),
            ],
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: cardDark,
      child: Icon(
        Icons.person,
        size: 48,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Row(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  // Content Tabs
  Widget _buildContentTabs() {
    return Container(
      color: backgroundDark,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _buildTab('Video', 0),
          const SizedBox(width: 12),
          _buildTab('Bộ sưu tập', 1),
          const SizedBox(width: 12),
          _buildTab('Hiệu quả', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isActive = _selectedTabIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? primaryGold : cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? primaryGold : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.black : Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // Tab Content
  Widget _buildTabContent() {
    if (_selectedTabIndex == 0) {
      return _buildVideoGrid();
    } else if (_selectedTabIndex == 1) {
      return _buildEmptyState('Chưa có bộ sưu tập nào');
    } else {
      return _buildEmptyState('Dữ liệu hiệu quả đang được cập nhật');
    }
  }

  // Video Grid
  Widget _buildVideoGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 20,
          childAspectRatio: 0.65,
        ),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          return _buildVideoCard(_videos[index], index);
        },
      ),
    );
  }

  Widget _buildVideoCard(VideoItem video, int index) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phát video: ${video.title}')),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Thumbnail Image
                    Image.network(
                      video.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: cardDark,
                          child: Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              size: 48,
                              color: Colors.grey[700],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Duration Badge
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.duration,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    // Play overlay (subtle)
                    Center(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Title
          Text(
            video.title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideY(
      begin: 0.2,
      duration: 400.ms,
      delay: (index * 50).ms,
    );
  }

  // Empty State
  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[700],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Floating Action Button
  Widget _buildFAB() {
    return GestureDetector(
      onTap: () {
        _showCreateVideoDialog();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: primaryGold.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add,
              color: Colors.black,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              'Tạo video mới',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).shimmer(
      duration: 2000.ms,
      color: Colors.white.withOpacity(0.3),
    );
  }

  // Create Video Dialog
  void _showCreateVideoDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardDarker,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              'Tạo video mới',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Options
            _buildCreateOption(
              icon: Icons.videocam,
              title: 'Quay video mới',
              subtitle: 'Sử dụng camera để quay video',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mở camera...')),
                );
              },
            ),
            
            const SizedBox(height: 12),
            
            _buildCreateOption(
              icon: Icons.photo_library,
              title: 'Chọn từ thư viện',
              subtitle: 'Tải video có sẵn lên',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mở thư viện...')),
                );
              },
            ),
            
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: primaryGold,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}

// Sticky Tab Bar Delegate
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 64;

  @override
  double get maxExtent => 64;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}

// Video Item Model
class VideoItem {
  final String thumbnail;
  final String title;
  final String duration;

  VideoItem({
    required this.thumbnail,
    required this.title,
    required this.duration,
  });
}
