import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/supabase_service.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'teacher_schedule_screen.dart';
import 'student_management_screen.dart';
import 'messages_screen.dart';
import 'teacher_wallet_screen.dart';
import 'teacher_reviews_screen.dart';
import 'teacher_public_profile_screen.dart';
import 'affiliate_dashboard_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final _supabaseService = SupabaseService();
  
  bool _isOnline = true;
  int _currentNavIndex = 0;
  bool _isLoading = true;
  
  // Teacher profile data from database
  String _teacherName = '';
  String? _avatarUrl;
  int _totalIncome = 0;
  double _rating = 0.0;
  int _ratingCount = 0;
  int _totalStudents = 0;
  int _weekSessions = 0;

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    try {
      final profile = await _supabaseService.getTeacherProfile();
      
      if (profile != null && mounted) {
        setState(() {
          _teacherName = profile['full_name'] ?? 'Giáo viên';
          _avatarUrl = profile['avatar_url'];
          // TODO: Calculate these from bookings table when implemented
          _totalIncome = 18200000; // Placeholder
          _rating = 4.9; // Placeholder
          _ratingCount = 248; // Placeholder
          _totalStudents = 32; // Placeholder
          _weekSessions = 18; // Placeholder
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading teacher data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header Area
                    _buildHeader(),
                    const SizedBox(height: 24),
                    
                    // 2. Status Bar
                    _buildStatusBar(),
                    const SizedBox(height: 24),
                    
                    // 3. Statistics Overview
                    _buildStatistics(),
                    const SizedBox(height: 24),
                    
                    // 4. Action Section
                    _buildActionSection(),
                    const SizedBox(height: 24),
                    
                    // 5. Today's Schedule
                    _buildTodaySchedule(),
                    const SizedBox(height: 80), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // 1. HEADER AREA
  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chào Thầy/Cô ${_teacherName.split(' ').last} 👋',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 4),
              Text(
                'Chúc thầy/cô có một ngày dạy tuyệt vời!',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Affiliate Button
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AffiliateDashboardScreen(),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
              ),
            ),
            child: const Icon(
              Icons.attach_money,
              color: Color(0xFFD4AF37),
              size: 24,
            ),
          ),
        ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.8, 0.8)),
        const SizedBox(width: 8),
        // Notification Bell
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                ),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFFD4AF37),
                size: 24,
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 350.ms).scale(begin: const Offset(0.8, 0.8)),
        const SizedBox(width: 8),
        // Logout Button
        GestureDetector(
          onTap: _handleLogout,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
              ),
            ),
            child: const Icon(
              Icons.logout,
              color: Color(0xFFD4AF37),
              size: 24,
            ),
          ),
        ).animate().fadeIn(delay: 350.ms).scale(begin: const Offset(0.8, 0.8)),
        const SizedBox(width: 12),
        // Avatar
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeacherPublicProfileScreen(
                  teacherName: _teacherName,
                  teacherAvatar: _avatarUrl,
                ),
              ),
            );
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.5),
                width: 2,
              ),
              image: DecorationImage(
                image: _avatarUrl != null
                    ? NetworkImage(_avatarUrl!)
                    : const NetworkImage('https://i.pravatar.cc/150?img=33'),
                fit: BoxFit.cover,
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.8, 0.8)),
        ),
      ],
    );
  }

  // 2. STATUS BAR
  Widget _buildStatusBar() {
    return Row(
      children: [
        // Toggle 1: Online Status
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _isOnline = !_isOnline);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFD4AF37),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _isOnline ? 'Online: Bật' : 'Online: Tắt',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
        ),
        const SizedBox(width: 10),
        // Toggle 2: Sessions This Week
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFFD4AF37),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Tuần: $_weekSessions buổi',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2),
        ),
      ],
    );
  }

  // 3. STATISTICS OVERVIEW
  Widget _buildStatistics() {
    return Row(
      children: [
        // Card 1: Income (Tappable)
        Expanded(
          child: _buildStatCard(
            label: 'Thu nhập tháng',
            value: '${_formatCurrency(_totalIncome)}đ',
            valueColor: const Color(0xFFD4AF37),
            subtitle: '',
            delay: 100,
            showArrow: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherWalletScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        // Card 2: Rating (Tappable)
        Expanded(
          child: _buildStatCard(
            label: 'Đánh giá',
            value: '$_rating ⭐',
            valueColor: Colors.white,
            subtitle: '($_ratingCount)',
            delay: 200,
            showArrow: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherReviewsScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        // Card 3: Students - Tappable
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentManagementScreen(),
                ),
              );
            },
            child: _buildStatCard(
              label: 'Học viên',
              value: '$_totalStudents',
              valueColor: Colors.white,
              subtitle: 'Đang hoạt động',
              delay: 300,
              showArrow: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color valueColor,
    required String subtitle,
    required int delay,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    final cardContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (showArrow)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: const Color(0xFFD4AF37).withOpacity(0.6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: valueColor,
              letterSpacing: -0.5,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ],
      ),
    );
    
    final animatedCard = cardContent.animate().fadeIn(delay: delay.ms).scale(begin: const Offset(0.9, 0.9));
    
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: animatedCard,
      );
    }
    
    return animatedCard;
  }

  // 4. ACTION SECTION
  Widget _buildActionSection() {
    return Column(
      children: [
        // Card A: Upcoming Session
        _buildUpcomingSession(),
        const SizedBox(height: 16),
        // Card B: New Requests
        _buildNewRequests(),
      ],
    );
  }

  Widget _buildUpcomingSession() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4AF37).withOpacity(0.15),
            const Color(0xFF1E1E1E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Còn 2 giờ',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Buổi học sắp tới',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '19:30 - 20:30',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person_outline, size: 18, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Text(
                'Học viên: Ánh',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.video_call_outlined, size: 18, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Text(
                'Hình thức: Online 1-1',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Xem chi tiết',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildNewRequests() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Yêu cầu mới',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '3',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRequestItem('Minh', 'Offline', Icons.people_outline),
          const SizedBox(height: 12),
          _buildRequestItem('Hà My', 'Online', Icons.computer_outlined),
          const SizedBox(height: 12),
          _buildRequestItem('Tuấn Anh', 'Online', Icons.computer_outlined),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD4AF37)),
                foregroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Xem tất cả',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2);
  }

  Widget _buildRequestItem(String name, String type, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFFD4AF37)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                type,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: Colors.grey[500]),
      ],
    );
  }

  // 5. TODAY'S SCHEDULE
  Widget _buildTodaySchedule() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lớp hôm nay',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          _buildTimelineItem(
            time: '17:00',
            title: 'Piano Cơ bản',
            type: 'Offline',
            icon: Icons.people_outline,
            isFirst: true,
          ),
          _buildTimelineItem(
            time: '19:30',
            title: '1-1',
            type: 'Online',
            icon: Icons.computer_outlined,
            isLast: false,
          ),
          _buildTimelineItem(
            time: '21:00',
            title: 'Jazz Piano',
            type: 'Offline',
            icon: Icons.people_outline,
            isLast: true,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFB8941F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TeacherScheduleScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Mở lịch',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required String type,
    required IconData icon,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: const Color(0xFFD4AF37).withOpacity(0.3),
              ),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF121212),
                  width: 2,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: const Color(0xFFD4AF37).withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.grey[700],
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
                      Row(
                        children: [
                          Icon(icon, size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            type,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.grey[400],
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
        ),
      ],
    );
  }

  // 6. BOTTOM NAVIGATION BAR
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Dashboard',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
                label: 'Lịch',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.message_outlined,
                activeIcon: Icons.message,
                label: 'Tin nhắn',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Hồ sơ',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HELPER METHODS
  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Đăng xuất',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất?',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Không', style: GoogleFonts.inter(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Đăng xuất', style: GoogleFonts.inter(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      await _supabaseService.signOut();
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Profile Info
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.5),
                      width: 2,
                    ),
                    image: DecorationImage(
                      image: _avatarUrl != null
                          ? NetworkImage(_avatarUrl!)
                          : const NetworkImage('https://i.pravatar.cc/150?img=33'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _teacherName,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _supabaseService.currentUser?.email ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Color(0xFF2E2E2E)),
            const SizedBox(height: 12),
            // Menu Items
            _buildMenuItem(
              icon: Icons.person_outline,
              label: 'Xem hồ sơ',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Tính năng đang được phát triển',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFF1E1E1E),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.edit_outlined,
              label: 'Chỉnh sửa hồ sơ',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Tính năng đang được phát triển',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFF1E1E1E),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              label: 'Cài đặt',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Tính năng đang được phát triển',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFF1E1E1E),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF2E2E2E)),
            const SizedBox(height: 12),
            _buildMenuItem(
              icon: Icons.logout,
              label: 'Đăng xuất',
              isDestructive: true,
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E1E),
                    title: Text(
                      'Đăng xuất',
                      style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      'Bạn có chắc chắn muốn đăng xuất?',
                      style: GoogleFonts.inter(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('Không', style: GoogleFonts.inter(color: Colors.white60)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text('Đăng xuất', style: GoogleFonts.inter(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true && context.mounted) {
                  await _supabaseService.signOut();
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.redAccent : const Color(0xFFD4AF37),
        size: 24,
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.redAccent : Colors.white,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      hoverColor: const Color(0xFFD4AF37).withOpacity(0.1),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          // Already on Dashboard, just update state
          setState(() => _currentNavIndex = 0);
        } else if (index == 1) {
          // Navigate to Schedule
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TeacherScheduleScreen(),
            ),
          );
        } else if (index == 2) {
          // Navigate to Messages
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MessagesScreen(),
            ),
          );
        } else if (index == 3) {
          // Show Profile Menu
          _showProfileMenu(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFD4AF37).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? const Color(0xFFD4AF37) : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? const Color(0xFFD4AF37) : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
