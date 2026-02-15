import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart';
import '../models/learner_stats.dart';
import 'login_screen.dart';

class LearnerDashboardScreen extends StatefulWidget {
  const LearnerDashboardScreen({super.key});

  @override
  State<LearnerDashboardScreen> createState() => _LearnerDashboardScreenState();
}

class _LearnerDashboardScreenState extends State<LearnerDashboardScreen> {
  final _supabaseService = SupabaseService();
  
  bool _isLoading = true;
  LearnerStats? _stats;
  List<Map<String, dynamic>> _upcomingBookings = [];
  List<Map<String, dynamic>> _activeRentals = [];
  List<Map<String, dynamic>> _enrolledCourses = [];
  Map<String, dynamic>? _userProfile;

  // Colors
  final Color primaryGold = const Color(0xFFD4AF37);
  final Color backgroundLight = const Color(0xFFF8F6F0);
  final Color cardLight = const Color(0xFFFFFFFF);
  final Color textDark = const Color(0xFF1A1A1A);
  final Color textGray = const Color(0xFF6B6B6B);

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load all data in parallel
      final results = await Future.wait([
        _supabaseService.getLearnerStats(),
        _supabaseService.getLearnerUpcomingBookings(),
        _supabaseService.getLearnerActiveRentals(),
        _supabaseService.getLearnerEnrolledCourses(),
        _supabaseService.getMyProfile(),
      ]);

      if (mounted) {
        setState(() {
          _stats = results[0] as LearnerStats?;
          _upcomingBookings = results[1] as List<Map<String, dynamic>>;
          _activeRentals = results[2] as List<Map<String, dynamic>>;
          _enrolledCourses = results[3] as List<Map<String, dynamic>>;
          _userProfile = results[4] as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('[LearnerDashboard] Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundLight,
        body: Center(
          child: CircularProgressIndicator(color: primaryGold),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundLight,
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: primaryGold,
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            _buildQuickStats(),
            _buildCoursesSection(),
            _buildUpcomingBookingsSection(),
            _buildRentalsSection(),
            _buildPaymentSection(),
            _buildAffiliateSection(),
            _buildSettingsSection(),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100), // Bottom padding
            ),
          ],
        ),
      ),
    );
  }

  // ========== HEADER ==========
  Widget _buildHeader() {
    final name = _userProfile?['full_name'] ?? 'Học viên';
    final avatarUrl = _userProfile?['avatar_url'];
    
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryGold,
              primaryGold.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        image: avatarUrl != null
                            ? DecorationImage(
                                image: NetworkImage(avatarUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      child: avatarUrl == null
                          ? Icon(Icons.person, size: 35, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    
                    // Name & Badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '🎓 Học viên',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== QUICK STATS ==========
  Widget _buildQuickStats() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildStatCard(
              icon: Icons.check_circle,
              label: 'Đã hoàn thành',
              value: '${_stats?.completedBookings ?? 0}',
              color: Colors.green,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.calendar_today,
              label: 'Sắp tới',
              value: '${_stats?.upcomingBookings ?? 0}',
              color: Colors.blue,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              icon: Icons.piano,
              label: 'Đàn đang thuê',
              value: '${_stats?.activeRentals ?? 0}',
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== COURSES SECTION ==========
  Widget _buildCoursesSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📚 Khóa học của tôi',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                if (_enrolledCourses.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to all courses
                    },
                    child: Text(
                      'Xem tất cả',
                      style: GoogleFonts.inter(color: primaryGold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (_enrolledCourses.isEmpty)
              _buildEmptyState(
                icon: Icons.school,
                title: 'Chưa có khóa học',
                subtitle: 'Tìm giáo viên ở tab Explore để bắt đầu học!',
                actionLabel: 'Khám phá ngay',
                onAction: () {
                  // TODO: Switch to Explore tab
                },
              )
            else
              ..._enrolledCourses.take(3).map((course) => 
                _buildCourseCard(course)
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final teacherName = course['teacher_name'] ?? 'Unknown';
    final teacherAvatar = course['teacher_avatar'];
    final courseName = course['course_name'] ?? 'Piano Course';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Teacher Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: teacherAvatar != null
                  ? DecorationImage(
                      image: NetworkImage(teacherAvatar),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: primaryGold.withOpacity(0.2),
            ),
            child: teacherAvatar == null
                ? Icon(Icons.person, color: primaryGold, size: 30)
                : null,
          ),
          const SizedBox(width: 16),
          
          // Course Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacherName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  courseName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: textGray,
                  ),
                ),
              ],
            ),
          ),
          
          // Actions
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: Book a lesson
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Đặt lịch',
                  style: GoogleFonts.inter(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== UPCOMING BOOKINGS SECTION ==========
  Widget _buildUpcomingBookingsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⏰ Lịch học sắp tới',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            
            if (_upcomingBookings.isEmpty)
              _buildEmptyState(
                icon: Icons.event_available,
                title: 'Chưa có lịch học',
                subtitle: 'Đặt buổi học với giáo viên để bắt đầu!',
              )
            else
              ..._upcomingBookings.take(3).map((booking) => 
                _buildBookingCard(booking)
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final teacherName = booking['teacher_name'] ?? 'Unknown';
    final startTime = booking['start_time'] ?? '';
    final duration = booking['duration'] ?? 60;
    final status = booking['status'] ?? 'confirmed';
    
    Color statusColor = Colors.green;
    if (status == 'pending') statusColor = Colors.orange;
    if (status == 'cancelled') statusColor = Colors.red;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                teacherName,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: textGray),
              const SizedBox(width: 8),
              Text(
                startTime,
                style: GoogleFonts.inter(fontSize: 14, color: textGray),
              ),
              const SizedBox(width: 16),
              Icon(Icons.timer, size: 16, color: textGray),
              const SizedBox(width: 8),
              Text(
                '$duration phút',
                style: GoogleFonts.inter(fontSize: 14, color: textGray),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: View booking details
                  },
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Chi tiết'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryGold,
                    side: BorderSide(color: primaryGold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Join meeting room
                  },
                  icon: const Icon(Icons.video_call, size: 18),
                  label: const Text('Vào lớp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== RENTALS SECTION ==========
  Widget _buildRentalsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎹 Đàn đang thuê',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            
            if (_activeRentals.isEmpty)
              _buildEmptyState(
                icon: Icons.piano,
                title: 'Chưa thuê đàn',
                subtitle: 'Thuê đàn để tập luyện tại nhà!',
                actionLabel: 'Xem đàn cho thuê',
                onAction: () {
                  // TODO: Navigate to piano rentals
                },
              )
            else
              ..._activeRentals.map((rental) => _buildRentalCard(rental)),
          ],
        ),
      ),
    );
  }

  Widget _buildRentalCard(Map<String, dynamic> rental) {
    final pianoName = rental['piano_name'] ?? 'Unknown Piano';
    final startDate = rental['start_date'] ?? '';
    final endDate = rental['end_date'] ?? '';
    final monthlyPrice = rental['monthly_price'] ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pianoName,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: textGray),
              const SizedBox(width: 8),
              Text(
                '$startDate → $endDate',
                style: GoogleFonts.inter(fontSize: 14, color: textGray),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${monthlyPrice.toStringAsFixed(0)}₫/tháng',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryGold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: View contract
                  },
                  child: const Text('Xem hợp đồng'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryGold,
                    side: BorderSide(color: primaryGold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Extend rental
                  },
                  child: const Text('Gia hạn'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== PAYMENT SECTION ==========
  Widget _buildPaymentSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💳 Thanh toán',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryGold, primaryGold.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryGold.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Tổng chi phí',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_stats?.totalSpent ?? 0).toStringAsFixed(0)}₫',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: View payment history
                    },
                    icon: const Icon(Icons.history, size: 18),
                    label: const Text('Xem lịch sử'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryGold,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== AFFILIATE SECTION ==========
  Widget _buildAffiliateSection() {
    final affiliateEarnings = _stats?.affiliateEarnings ?? 0;
    final referralCode = _userProfile?['id']?.toString().substring(0, 8).toUpperCase() ?? 'XXXXX';
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎁 Giới thiệu bạn bè',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryGold.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hoa hồng của bạn',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: textGray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${affiliateEarnings.toStringAsFixed(0)}₫',
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: primaryGold,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.trending_up, size: 48, color: primaryGold),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: backgroundLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Mã giới thiệu: $referralCode',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: referralCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã sao chép mã giới thiệu!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: Icon(Icons.copy, color: primaryGold),
                        style: IconButton.styleFrom(
                          backgroundColor: primaryGold.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== SETTINGS SECTION ==========
  Widget _buildSettingsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚙️ Cài đặt',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: cardLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.person,
                    title: 'Thông tin cá nhân',
                    onTap: () {
                      // TODO: Edit profile
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.lock,
                    title: 'Đổi mật khẩu',
                    onTap: () {
                      // TODO: Change password
                    },
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.star,
                    title: 'Nâng cấp thành giáo viên',
                    subtitle: 'Bắt đầu dạy học và kiếm tiền',
                    onTap: () {
                      // TODO: Navigate to teacher upgrade flow
                    },
                    trailing: Icon(Icons.arrow_forward, color: primaryGold),
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    icon: Icons.logout,
                    title: 'Đăng xuất',
                    titleColor: Colors.red,
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xác nhận'),
                          content: const Text('Bạn có chắc muốn đăng xuất?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                'Đăng xuất',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirm == true) {
                        await _supabaseService.signOut();
                        if (mounted) {
                          // Navigate to login screen
                          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (titleColor ?? primaryGold).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: titleColor ?? primaryGold, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: titleColor ?? textDark,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 12, color: textGray),
            )
          : null,
      trailing: trailing ?? Icon(Icons.chevron_right, color: textGray),
    );
  }

  // ========== EMPTY STATE ==========
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textGray.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 64, color: textGray.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textGray,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(actionLabel, style: GoogleFonts.inter()),
            ),
          ],
        ],
      ),
    );
  }
}
