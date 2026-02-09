import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherPublicProfileScreen extends StatefulWidget {
  final String? teacherName;
  final String? teacherAvatar;

  const TeacherPublicProfileScreen({
    Key? key,
    this.teacherName,
    this.teacherAvatar,
  }) : super(key: key);

  @override
  State<TeacherPublicProfileScreen> createState() =>
      _TeacherPublicProfileScreenState();
}

class _TeacherPublicProfileScreenState
    extends State<TeacherPublicProfileScreen> {
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB39129);
  static const Color backgroundLight = Color(0xFFF6F7FB);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardAlt = Color(0xFFF1F4F9);
  static const Color textDark = Color(0xFF111827);
  static const Color textMuted = Color(0xFF667085);
  static const Color borderLight = Color(0xFFE4E7EC);

  int _selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();

  final String _likes = '128K';
  final String _followers = '2.4K';
  final String _bio =
      'Chia se hanh trinh hoc piano tu so 0.\nBeginner | Luyen ngon | Cover';

  final List<VideoItem> _videos = [
    VideoItem(
      thumbnail: 'https://picsum.photos/400/600?random=1',
      title: 'Luyen ngon 5 phut',
      duration: '0:32',
    ),
    VideoItem(
      thumbnail: 'https://picsum.photos/400/600?random=2',
      title: 'Cover Ballad',
      duration: '1:15',
    ),
    VideoItem(
      thumbnail: 'https://picsum.photos/400/600?random=3',
      title: 'Bai 1 cho nguoi moi',
      duration: '10:00',
    ),
    VideoItem(
      thumbnail: 'https://picsum.photos/400/600?random=4',
      title: '88 phim vs 61 phim',
      duration: '0:32',
    ),
    VideoItem(
      thumbnail: 'https://picsum.photos/400/600?random=5',
      title: 'Ky thuat pedal co ban',
      duration: '2:45',
    ),
    VideoItem(
      thumbnail: 'https://picsum.photos/400/600?random=6',
      title: 'Choi hop am dau tien',
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
    final displayName = widget.teacherName ?? 'Linh Nguyen';
    final displayAvatar = widget.teacherAvatar;

    return Scaffold(
      backgroundColor: backgroundLight,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: _buildProfileHeader(displayName, displayAvatar),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  child: _buildContentTabs(),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildTabContent(),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: _buildBackButton(),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(child: _buildFAB()),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: cardLight,
          shape: BoxShape.circle,
          border: Border.all(color: borderLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: textDark,
          size: 18,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildProfileHeader(String name, String? avatar) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 72,
        20,
        28,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFBF0),
            Color(0xFFF7F9FD),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryGold, width: 3),
              boxShadow: [
                BoxShadow(
                  color: primaryGold.withOpacity(0.28),
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
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                    )
                  : _buildDefaultAvatar(),
            ),
          ).animate().scale(
                begin: const Offset(0.82, 0.82),
                duration: 500.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: 18),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: primaryGold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryGold, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, color: primaryGold, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Giao vien da xac thuc',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: darkGold,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(
                begin: 0.2,
                duration: 400.ms,
              ),
          const SizedBox(height: 18),
          Text(
            _bio,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textMuted,
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem(_likes, 'luot thich'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: borderLight,
                  shape: BoxShape.circle,
                ),
              ),
              _buildStatItem(_followers, 'nguoi theo doi'),
            ],
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: cardAlt,
      child: Icon(Icons.person, size: 48, color: Colors.grey[500]),
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
            color: textDark,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildContentTabs() {
    return Container(
      color: backgroundLight,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          _buildTab('Video', 0),
          const SizedBox(width: 12),
          _buildTab('Bo suu tap', 1),
          const SizedBox(width: 12),
          _buildTab('Hieu qua', 2),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? primaryGold : cardLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? primaryGold : borderLight,
              width: 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: primaryGold.withOpacity(0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.black : textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedTabIndex == 0) {
      return _buildVideoGrid();
    }
    if (_selectedTabIndex == 1) {
      return _buildEmptyState('Chua co bo suu tap nao');
    }
    return _buildEmptyState('Du lieu hieu qua dang duoc cap nhat');
  }

  Widget _buildVideoGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 104),
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
          SnackBar(content: Text('Phat video: ${video.title}')),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: cardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderLight, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      video.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return Container(
                          color: cardAlt,
                          child: Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              size: 48,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
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
                    Center(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow,
                            color: Colors.black87, size: 28),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            video.title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textDark,
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

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[500]),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: _showCreateVideoDialog,
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
            const Icon(Icons.add, color: Colors.black, size: 24),
            const SizedBox(width: 10),
            Text(
              'Tao video moi',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(
          duration: 2000.ms,
          color: Colors.white.withOpacity(0.3),
        );
  }

  void _showCreateVideoDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
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
              'Tao video moi',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 24),
            _buildCreateOption(
              icon: Icons.videocam,
              title: 'Quay video moi',
              subtitle: 'Su dung camera de quay video',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Mo camera...')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildCreateOption(
              icon: Icons.photo_library,
              title: 'Chon tu thu vien',
              subtitle: 'Tai video co san len',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Mo thu vien...')),
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
          color: cardAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderLight, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryGold.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: darkGold, size: 24),
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
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 64;

  @override
  double get maxExtent => 64;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}

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
