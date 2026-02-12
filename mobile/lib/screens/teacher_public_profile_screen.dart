import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/feed_item.dart';
import '../services/supabase_service.dart';
import 'upload_video_screen.dart';
import 'video_player_detail_screen.dart';

class TeacherPublicProfileScreen extends StatefulWidget {
  final String? teacherName;
  final String? teacherAvatar;
  final String? teacherUserId;

  const TeacherPublicProfileScreen({
    super.key,
    this.teacherName,
    this.teacherAvatar,
    this.teacherUserId,
  });

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

  final SupabaseService _supabaseService = SupabaseService();
  final ScrollController _scrollController = ScrollController();

  int _selectedTabIndex = 0;
  bool _isLoading = true;
  bool _isFollowLoading = false;
  String? _targetUserId;
  String _displayName = 'Creator';
  String? _displayAvatar;
  String _bio = 'Chia se hanh trinh hoc piano tu so 0.';
  bool _isFollowing = false;
  int _followersCount = 0;
  int _followingCount = 0;
  int _postsCount = 0;
  List<FeedItem> _videos = const [];

  String? get _currentUserId => _supabaseService.currentUser?.id;
  bool get _isOwnProfile =>
      _targetUserId != null &&
      _currentUserId != null &&
      _targetUserId == _currentUserId;
  bool get _canFollow =>
      _targetUserId != null &&
      _currentUserId != null &&
      _targetUserId != _currentUserId;

  @override
  void initState() {
    super.initState();
    _displayName = widget.teacherName?.trim().isNotEmpty == true
        ? widget.teacherName!.trim()
        : _displayName;
    _displayAvatar = widget.teacherAvatar;
    _targetUserId = widget.teacherUserId ?? _currentUserId;
    _loadProfile();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    final targetUserId = _targetUserId;
    if (targetUserId == null || targetUserId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final results = await Future.wait([
        _supabaseService.getTeacherProfileByUserId(targetUserId),
        _supabaseService.getProfileStats(targetUserId),
        _supabaseService.getCreatorFeedItems(authorId: targetUserId, limit: 60),
        _canFollow
            ? _supabaseService.isFollowing(targetUserId)
            : Future<bool>.value(false),
      ]);

      final profile = results[0] as Map<String, dynamic>?;
      final stats = results[1] as Map<String, int>;
      final videos = results[2] as List<FeedItem>;
      final following = results[3] as bool;

      if (!mounted) return;
      setState(() {
        _displayName =
            (profile?['full_name'] as String?)?.trim().isNotEmpty == true
                ? (profile!['full_name'] as String).trim()
                : _displayName;
        _displayAvatar =
            (profile?['avatar_url'] as String?)?.trim().isNotEmpty == true
                ? (profile!['avatar_url'] as String).trim()
                : _displayAvatar;
        final profileBio = (profile?['bio'] as String?)?.trim();
        if (profileBio != null && profileBio.isNotEmpty) {
          _bio = profileBio;
        }
        _followersCount = stats['followers_count'] ?? 0;
        _followingCount = stats['following_count'] ?? 0;
        _postsCount = stats['posts_count'] ?? videos.length;
        _videos = videos;
        _isFollowing = following;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    final targetUserId = _targetUserId;
    if (!_canFollow || targetUserId == null) return;
    if (_isFollowLoading) return;

    final previousFollowing = _isFollowing;
    final optimisticFollowing = !previousFollowing;
    setState(() {
      _isFollowLoading = true;
      _isFollowing = optimisticFollowing;
      _followersCount += optimisticFollowing ? 1 : -1;
      if (_followersCount < 0) _followersCount = 0;
    });

    try {
      final serverFollowing = await _supabaseService.toggleFollow(targetUserId);
      if (!mounted) return;
      setState(() {
        if (serverFollowing != optimisticFollowing) {
          _followersCount += serverFollowing ? 1 : -1;
          if (_followersCount < 0) _followersCount = 0;
        }
        _isFollowing = serverFollowing;
        _isFollowLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFollowing = previousFollowing;
        _followersCount += previousFollowing ? 1 : -1;
        if (_followersCount < 0) _followersCount = 0;
        _isFollowLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Follow failed: $e', style: GoogleFonts.inter()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openUploadVideo() async {
    final posted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const UploadVideoScreen(videoPath: null),
      ),
    );
    if (posted == true) {
      await _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: _buildProfileHeader(),
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
          if (_isOwnProfile)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(child: _buildCreateVideoButton()),
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
        child: const Icon(Icons.arrow_back_ios_new, color: textDark, size: 18),
      ),
    ).animate().fadeIn(duration: 280.ms);
  }

  Widget _buildProfileHeader() {
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
          colors: [Color(0xFFFFFBF0), Color(0xFFF7F9FD)],
        ),
      ),
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 16),
          Text(
            _displayName,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          if (_canFollow) _buildFollowButton(),
          if (_canFollow) const SizedBox(height: 14),
          Text(
            _bio,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textMuted,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: primaryGold, width: 3),
        boxShadow: [
          BoxShadow(
            color: primaryGold.withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: _displayAvatar != null && _displayAvatar!.isNotEmpty
            ? Image.network(
                _displayAvatar!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
              )
            : _buildDefaultAvatar(),
      ),
    ).animate().scale(
          begin: const Offset(0.88, 0.88),
          duration: 420.ms,
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: cardAlt,
      child: Icon(Icons.person, size: 50, color: Colors.grey[500]),
    );
  }

  Widget _buildFollowButton() {
    final isFollowing = _isFollowing;
    return ElevatedButton(
      onPressed: _isFollowLoading ? null : _toggleFollow,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: isFollowing ? cardLight : primaryGold,
        foregroundColor: isFollowing ? textDark : Colors.black,
        side: BorderSide(color: isFollowing ? borderLight : primaryGold),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isFollowLoading)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          if (_isFollowLoading) const SizedBox(width: 8),
          Text(
            isFollowing ? 'Following' : 'Follow',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(_postsCount, 'Bai dang'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(_followersCount, 'Follower'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(_followingCount, 'Following'),
        ),
      ],
    );
  }

  Widget _buildStatCard(int value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderLight),
      ),
      child: Column(
        children: [
          Text(
            _formatCount(value),
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  Widget _buildContentTabs() {
    return Container(
      color: backgroundLight,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          _buildTab('Video', 0),
          const SizedBox(width: 10),
          _buildTab('Bo suu tap', 1),
          const SizedBox(width: 10),
          _buildTab('Hieu qua', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isActive = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? primaryGold : cardLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isActive ? primaryGold : borderLight,
              width: 1,
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.black : textMuted,
            ),
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
    return _buildEmptyState('Du lieu hieu qua dang cap nhat');
  }

  Widget _buildVideoGrid() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator(color: primaryGold)),
      );
    }

    if (_videos.isEmpty) {
      return _buildEmptyState('Chua co video nao');
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, _isOwnProfile ? 108 : 32),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 18,
          childAspectRatio: 0.65,
        ),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          return _buildVideoCard(_videos[index], index);
        },
      ),
    );
  }

  Widget _buildVideoCard(FeedItem video, int index) {
    final thumbnail = (video.thumbUrl ?? video.mediaUrl).trim();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerDetailScreen(
              videoTitle: video.caption.trim().isNotEmpty
                  ? video.caption.trim()
                  : 'Video',
              duration: '--:--',
              thumbnail: thumbnail,
              author: _displayName,
            ),
          ),
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
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    thumbnail.isEmpty
                        ? Container(
                            color: cardAlt,
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[500],
                            ),
                          )
                        : Image.network(
                            thumbnail,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: cardAlt,
                              child: Icon(
                                Icons.play_circle_outline,
                                color: Colors.grey[600],
                                size: 40,
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
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.black87,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            video.caption.trim().isNotEmpty ? video.caption.trim() : 'Video',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 45).ms);
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 76),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[500]),
          const SizedBox(height: 14),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateVideoButton() {
    return GestureDetector(
      onTap: _openUploadVideo,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE6C86E), Color(0xFFBF953F), Color(0xFFE6C86E)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: primaryGold.withOpacity(0.4),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Colors.black, size: 22),
            const SizedBox(width: 8),
            Text(
              'Tao video moi',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
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
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) {
    return false;
  }
}
