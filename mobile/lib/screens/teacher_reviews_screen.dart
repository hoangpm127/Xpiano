import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../features/common/stub_helper.dart';

class TeacherReviewsScreen extends StatefulWidget {
  const TeacherReviewsScreen({Key? key}) : super(key: key);

  @override
  State<TeacherReviewsScreen> createState() => _TeacherReviewsScreenState();
}

class _TeacherReviewsScreenState extends State<TeacherReviewsScreen> {
  // Light Mode Palette
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB39129);
  static const Color backgroundDark = Color(0xFFF7F7F7);
  static const Color cardDark = Color(0xFFFFFFFF);
  static const Color cardDarker = Color(0xFFF1F1F1);
  static const Color borderLight = Color(0xFFE6E6E6);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B6B6B);

  // Rating data
  final double overallRating = 4.9;
  final int totalReviews = 248;
  final Map<int, int> ratingDistribution = {
    5: 212,
    4: 28,
    3: 5,
    2: 2,
    1: 1,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable Content
            CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(child: _buildHeader()),
                
                // Hero Score Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _buildHeroScoreCard(),
                  ),
                ),
                
                // Rating Distribution
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                    child: _buildRatingDistribution(),
                  ),
                ),
                
                // Achievements Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 32, 0, 0),
                    child: _buildAchievements(),
                  ),
                ),
                
                // Recent Reviews
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 100),
                    child: _buildRecentReviews(),
                  ),
                ),
              ],
            ),
            
            // Footer Action (Sticky Bottom)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildFooterAction(),
            ),
          ],
        ),
      ),
    );
  }

  // Header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundDark,
        border: Border(
          bottom: BorderSide(
            color: borderLight,
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
                border: Border.all(
                  color: borderLight,
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: textDark,
                size: 18,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Text(
              'Đánh giá & Thành tích',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
          ),
          
          // Info Button
          GestureDetector(
            onTap: () {
              _showInfoDialog();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: borderLight,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.info_outline,
                color: primaryGold,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hero Score Card
  Widget _buildHeroScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryGold.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGold.withOpacity(0.1),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Big Score
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                overallRating.toString(),
                style: GoogleFonts.inter(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 4),
                child: Text(
                  '/5',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: textMuted,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).scale(
            begin: const Offset(0.8, 0.8),
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
          
          const SizedBox(height: 16),
          
          // Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _buildStar(index),
              );
            }),
          ),
          
          const SizedBox(height: 16),
          
          // Count
          Text(
            'Dựa trên $totalReviews đánh giá',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textMuted,
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildStar(int index) {
    final rating = overallRating;
    IconData iconData;
    
    if (index < rating.floor()) {
      iconData = Icons.star;
    } else if (index < rating) {
      iconData = Icons.star_half;
    } else {
      iconData = Icons.star_border;
    }
    
    return Icon(
      iconData,
      color: primaryGold,
      size: 32,
    ).animate().fadeIn(delay: (100 + index * 50).ms).scale(
      begin: const Offset(0.5, 0.5),
      duration: 300.ms,
      delay: (100 + index * 50).ms,
      curve: Curves.easeOutBack,
    );
  }

  // Rating Distribution
  Widget _buildRatingDistribution() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Phân bổ đánh giá',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Distribution Bars
        ...List.generate(5, (index) {
          final stars = 5 - index;
          final count = ratingDistribution[stars] ?? 0;
          final percentage = count / totalReviews;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildDistributionBar(stars, count, percentage, index),
          );
        }),
      ],
    );
  }

  Widget _buildDistributionBar(int stars, int count, double percentage, int index) {
    return Row(
      children: [
        // Star Label
        SizedBox(
          width: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$stars',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              Icon(
                Icons.star,
                color: primaryGold,
                size: 16,
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Progress Bar
        Expanded(
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: cardDarker,
              borderRadius: BorderRadius.circular(5),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryGold,
                      darkGold,
                      primaryGold,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
              ).animate().fadeIn(delay: (index * 100).ms).scaleX(
                begin: 0,
                duration: 600.ms,
                delay: (index * 100).ms,
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Count
        SizedBox(
          width: 40,
          child: Text(
            count.toString(),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textMuted,
            ),
          ),
        ),
      ],
    );
  }

  // Achievements Section
  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Thành tích',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Horizontal Scrolling Badges
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildAchievementBadge('🏆', 'Top Teacher', 0),
              const SizedBox(width: 12),
              _buildAchievementBadge('📅', '100+ buổi dạy', 100),
              const SizedBox(width: 12),
              _buildAchievementBadge('✅', 'Tỉ lệ hoàn tất 98%', 200),
              const SizedBox(width: 12),
              _buildAchievementBadge('⭐', 'Đánh giá xuất sắc', 300),
              const SizedBox(width: 12),
              _buildAchievementBadge('🎓', 'Chuyên gia', 400),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(String emoji, String label, int delay) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: primaryGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: primaryGold,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: primaryGold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(
      begin: 0.3,
      duration: 400.ms,
      delay: delay.ms,
      curve: Curves.easeOut,
    );
  }

  // Recent Reviews
  Widget _buildRecentReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nhận xét gần đây',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            TextButton(
              onPressed: () => openStub(
                context,
                'Xem tất cả đánh giá',
                'Danh sách đánh giá đầy đủ sẽ được bổ sung ở bản tiếp theo.',
                icon: Icons.reviews_outlined,
              ),
              child: Text(
                'Xem tất cả',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryGold,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Review Items
        _buildReviewItem(
          name: 'Ngọc Anh',
          avatar: 'https://i.pravatar.cc/150?img=5',
          rating: 5,
          time: '2 ngày trước',
          content: 'Cô hướng dẫn rất rõ ràng, bài tập phù hợp, tiến bộ nhanh.',
          delay: 0,
        ),
        
        _buildReviewItem(
          name: 'Minh Tuấn',
          avatar: 'https://i.pravatar.cc/150?img=12',
          rating: 5,
          time: '1 tuần trước',
          content: 'Phương pháp dạy hiệu quả, nhiệt tình và kiên nhẫn. Rất hài lòng!',
          delay: 100,
        ),
        
        _buildReviewItem(
          name: 'Thu Hằng',
          avatar: 'https://i.pravatar.cc/150?img=9',
          rating: 5,
          time: '2 tuần trước',
          content: 'Giáo viên tận tâm, giải đáp thắc mắc nhanh chóng. Con tôi rất thích!',
          delay: 200,
        ),
        
        _buildReviewItem(
          name: 'Bảo Trâm',
          avatar: 'https://i.pravatar.cc/150?img=20',
          rating: 4,
          time: '3 tuần trước',
          content: 'Dạy hay, chỉ có điều lịch học đôi khi hơi kín.',
          delay: 300,
        ),
      ],
    );
  }

  Widget _buildReviewItem({
    required String name,
    required String avatar,
    required int rating,
    required String time,
    required String content,
    required int delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryGold.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar + Name + Rating + Time
          Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryGold.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    avatar,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: cardDarker,
                        child: Icon(
                          Icons.person,
                          color: textMuted,
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Name + Rating Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: primaryGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            rating.toString(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: primaryGold,
                            ),
                          ),
                          Icon(
                            Icons.star,
                            color: primaryGold,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Time
              Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textMuted,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Review Content
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(
      begin: 0.2,
      duration: 400.ms,
      delay: delay.ms,
      curve: Curves.easeOut,
    );
  }

  // Footer Action
  Widget _buildFooterAction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundDark,
        border: Border(
          top: BorderSide(
            color: borderLight,
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
          // Subtext
          Text(
            'Tăng tỉ lệ nhận lớp bằng hồ sơ nổi bật',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Button
          GestureDetector(
            onTap: () => openStub(
              context,
              'Cải thiện hồ sơ',
              'Công cụ tối ưu hồ sơ sẽ có trong bản nâng cấp tiếp theo.',
              icon: Icons.auto_awesome,
            ),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Colors.black,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Cải thiện hồ sơ',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
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

  // Info Dialog
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDarker,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: primaryGold),
            const SizedBox(width: 12),
            Text(
              'Về đánh giá',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
          ],
        ),
        content: Text(
          'Đánh giá được tính dựa trên phản hồi thực tế từ học viên sau mỗi buổi học. Điểm cao giúp bạn nổi bật hơn trong danh sách giáo viên.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: textMuted,
            height: 1.5,
          ),
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
}

