import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../services/supabase_service.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'teacher_dashboard_screen.dart';
import 'learner_dashboard_screen.dart';
import 'teacher_profile_setup_screen.dart';
import 'admin_debug_screen.dart';
import 'affiliate_dashboard_screen.dart';
import 'piano_rental_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Constants
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color backgroundLight = Color(0xFFF7F7F7);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardAlt = Color(0xFFF1F1F1);
  static const Color borderLight = Color(0xFFE6E6E6);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B6B6B);
  final SupabaseService _supabaseService = SupabaseService();

  // State
  List<Booking> _bookings = [];
  bool _isLoading = true;
  Map<String, dynamic>? _teacherProfile;
  bool _isTeacher = false;
  String _currentRole = 'guest';
  bool _isUpgradingRole = false;
  int _adminTapCount = 0;

  String _normalizeRole(String? rawRole) {
    final role = (rawRole ?? '').trim().toLowerCase();
    if (role == 'teacher') return 'teacher';
    if (role == 'learner' || role == 'student') return 'learner';
    return 'guest';
  }

  @override
  void initState() {
    super.initState();
    _checkAuthAndFetch();
  }

  void _checkAuthAndFetch() async {
    final user = _supabaseService.currentUser;
    if (user == null) {
      // User is guest, don't fetch bookings
      setState(() {
        _currentRole = 'guest';
        _isTeacher = false;
        _teacherProfile = null;
        _isLoading = false;
      });
    } else {
      print('[_checkAuthAndFetch] 👤 User authenticated, fetching profile...');
      String fetchedRole = 'guest';
      try {
        final profile = await _supabaseService.getMyProfile(refresh: true);
        fetchedRole = _normalizeRole(profile['role']?.toString());
        print('[_checkAuthAndFetch] 📊 Profile from DB: role=${profile['role']}, normalized=$fetchedRole, full profile: $profile');
      } catch (e) {
        print('[_checkAuthAndFetch] ⚠️ Failed to fetch profile: $e');
        fetchedRole = _normalizeRole(
          _supabaseService.currentUser?.userMetadata?['role']?.toString(),
        );
        print('[_checkAuthAndFetch] 📋 Using metadata role: $fetchedRole');
      }

      // IMPORTANT: Don't override state if we're already in a more specific role
      // and this is just a background refresh
      if (_currentRole == 'teacher' && fetchedRole == 'guest') {
        print('[_checkAuthAndFetch] ⚠️ Skipping stale data: current=teacher but fetched=guest');
        setState(() => _isLoading = false);
        return;
      }

      // Check if user is a teacher
      final teacherProfile = await _supabaseService.getTeacherProfile();
      print('[_checkAuthAndFetch] 🎓 Teacher profile: ${teacherProfile != null ? "EXISTS" : "NULL"}');
      if (fetchedRole == 'teacher' || teacherProfile != null) {
        print('[_checkAuthAndFetch] ✅ Setting as TEACHER, role=$fetchedRole');
        setState(() {
          _currentRole = fetchedRole;
          _teacherProfile = teacherProfile;
          _isTeacher = true;
          _isLoading = false;
        });
      } else {
        print('[_checkAuthAndFetch] 👥 Setting as GUEST/LEARNER, role=$fetchedRole');
        // Regular guest/learner user
        setState(() {
          _currentRole = fetchedRole;
          _isTeacher = false;
          _teacherProfile = null;
        });
        _fetchBookings();
      }
    }
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    final bookings = await _supabaseService.getMyBookings();
    if (mounted) {
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleCancelBooking(int bookingId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardLight,
        title: Text('Xác nhận hủy',
            style: GoogleFonts.inter(
                color: textDark, fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn hủy lịch đặt này không?',
            style: GoogleFonts.inter(color: textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Không', style: GoogleFonts.inter(color: textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hủy Lịch',
                style: GoogleFonts.inter(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabaseService.cancelBooking(bookingId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã hủy lịch đặt thành công')),
          );
          _fetchBookings(); // Refresh list
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi hủy: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardLight,
        title: Text('Đăng xuất',
            style: GoogleFonts.inter(
                color: textDark, fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn đăng xuất?',
            style: GoogleFonts.inter(color: textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Không', style: GoogleFonts.inter(color: textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Đăng xuất',
                style: GoogleFonts.inter(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _supabaseService.signOut();
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _handleUpgradeRole(String targetRole) async {
    print('[_handleUpgradeRole] 🎯 Target: $targetRole, Current: $_currentRole');
    if (_isUpgradingRole || _currentRole != 'guest') return;

    setState(() => _isUpgradingRole = true);
    try {
      final upgradedRole = await _supabaseService.upgradeRole(targetRole);
      print('[_handleUpgradeRole] 📬 Got result: $upgradedRole');
      if (!mounted) {
        print('[_handleUpgradeRole] ⚠️ Widget not mounted after RPC!');
        return;
      }

      // Update state first
      setState(() {
        _currentRole = upgradedRole;
        _isTeacher = (upgradedRole == 'teacher');
        print('[_handleUpgradeRole] 🔄 setState: _currentRole = $_currentRole, _isTeacher = $_isTeacher');
      });

      // Use post-frame callback to ensure widget is stable before showing UI
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          print('[_handleUpgradeRole] ⚠️ Widget not mounted in post-frame callback!');
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              upgradedRole == 'teacher'
                  ? 'Đã nâng cấp Teacher. Vui lòng hoàn tất hồ sơ giáo viên.'
                  : 'Đã nâng cấp Learner thành công.',
            ),
          ),
        );

        if (upgradedRole == 'teacher') {
          print('[_handleUpgradeRole] 📝 Navigating to TeacherProfileSetupScreen...');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TeacherProfileSetupScreen(),
            ),
          ).then((_) {
            print('[_handleUpgradeRole] ⬅️ Returned from TeacherProfileSetupScreen');
            if (mounted) {
              print('[_handleUpgradeRole] 🔃 Calling _checkAuthAndFetch...');
              _checkAuthAndFetch();
            }
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString().toLowerCase();
      String message = 'Nâng cấp role thất bại: $e';
      bool shouldOpenTeacherSetup = false;
      if (raw.contains('infinite recursion detected in policy') &&
          raw.contains('profiles')) {
        message =
            'Lỗi cấu hình RLS của bảng profiles. Hãy chạy script mobile/scripts/profiles_rls_recursion_hotfix.sql trong Supabase SQL Editor rồi thử lại.';
      } else if (raw.contains('role_already_final')) {
        final match =
            RegExp(r'role_already_final[:\s]*([a-z_]+)').firstMatch(raw);
        final finalRole = _normalizeRole(match?.group(1));
        setState(() => _currentRole = finalRole);
        if (finalRole == 'teacher') {
          _isTeacher = true;
          final existingTeacherProfile =
              await _supabaseService.getTeacherProfile();
          shouldOpenTeacherSetup = existingTeacherProfile == null;
        }
        message =
            'Tài khoản đã chốt role: ${finalRole == 'teacher' ? 'Teacher' : 'Learner'}.';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      if (shouldOpenTeacherSetup && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TeacherProfileSetupScreen(),
          ),
        );
      }
      if (mounted) {
        _checkAuthAndFetch();
      }
    } finally {
      if (mounted) {
        setState(() => _isUpgradingRole = false);
      }
    }
  }

  Widget _buildRoleUpgradeCard() {
    if (_currentRole != 'guest') return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nâng cấp vai trò (1 lần duy nhất)',
            style: GoogleFonts.inter(
              color: textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isUpgradingRole
                      ? null
                      : () => _handleUpgradeRole('learner'),
                  child: Text(
                    'Thành Learner',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isUpgradingRole
                      ? null
                      : () => _handleUpgradeRole('teacher'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    foregroundColor: Colors.black,
                  ),
                  child: _isUpgradingRole
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Thành Teacher',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _supabaseService.currentUser;

    // If loading, show loading indicator
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundLight,
        body: Center(
          child: CircularProgressIndicator(color: primaryGold),
        ),
      );
    }

    // If user is a teacher with approved status, show full Teacher Dashboard
    if (_isTeacher && _teacherProfile?['verification_status'] == 'approved') {
      return const TeacherDashboardScreen();
    }

    // If user is a learner (not guest, not teacher), show Learner Dashboard
    if (_currentRole == 'learner') {
      return const LearnerDashboardScreen();
    }

    // Otherwise show normal profile screen with Scaffold
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: user == null
            ? _buildGuestView()
            : _isTeacher
                ? _buildTeacherPendingOrRejected()
                : Column(
                    children: [
                      // 1. Profile Header
                      _buildProfileHeader(isGuestRole: _currentRole == 'guest'),

                      _buildRoleUpgradeCard(),

                      const SizedBox(height: 20),

                      // 2. Section Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.history,
                                color: primaryGold, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Lịch sử đặt đàn',
                              style: GoogleFonts.inter(
                                color: textDark,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 3. Booking List
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: primaryGold))
                            : _bookings.isEmpty
                                ? _buildEmptyState()
                                : RefreshIndicator(
                                    onRefresh: _fetchBookings,
                                    color: primaryGold,
                                    backgroundColor: cardLight,
                                    child: ListView.separated(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: _bookings.length,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 16),
                                      itemBuilder: (context, index) {
                                        return _buildBookingCard(
                                            _bookings[index]);
                                      },
                                    ),
                                  ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildGuestView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() => _adminTapCount++);
                if (_adminTapCount >= 5) {
                  _adminTapCount = 0;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminDebugScreen(),
                    ),
                  );
                } else if (_adminTapCount >= 3) {
                  // Show hint when getting close
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${5 - _adminTapCount} lần nữa để mở Admin...',
                        style: GoogleFonts.inter(color: textDark),
                      ),
                      duration: const Duration(milliseconds: 500),
                      backgroundColor: cardLight,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Icon(
                Icons.person_outline,
                size: 80,
                color: primaryGold.withOpacity(_adminTapCount > 0 ? 0.8 : 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chào mừng đến Spiano!',
              style: GoogleFonts.inter(
                color: textDark,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Đăng nhập để xem hồ sơ và lịch sử đặt đàn của bạn',
              style: GoogleFonts.inter(
                color: textMuted,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE6C86E), Color(0xFFBF953F)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primaryGold.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  ).then((_) {
                    // Refresh profile after login
                    if (mounted) {
                      setState(() {
                        _checkAuthAndFetch();
                      });
                    }
                  });
                },
                child: Text(
                  'ĐĂNG NHẬP',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                ).then((_) {
                  // Refresh profile after registration
                  if (mounted) {
                    setState(() {
                      _checkAuthAndFetch();
                    });
                  }
                });
              },
              child: Text(
                'Chưa có tài khoản? Đăng ký ngay',
                style: GoogleFonts.inter(
                  color: primaryGold,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader({required bool isGuestRole}) {
    final user = _supabaseService.currentUser;
    final fullName = user?.userMetadata?['full_name'] ?? 'Người dùng';
    final email = user?.email ?? '';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, color: Colors.redAccent),
              ),
            ],
          ),
          const CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
                'https://via.placeholder.com/150'), // Placeholder avatar
            backgroundColor: Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            fullName,
            style: GoogleFonts.inter(
              color: textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: GoogleFonts.inter(
              color: textMuted,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isGuestRole ? 'Tài khoản Guest' : 'Thành viên Learner',
            style: GoogleFonts.inter(
              color: primaryGold,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('${_bookings.length}', 'Lịch thuê'),
              _buildStatItem(isGuestRole ? 'Guest' : 'Learner', 'Vai trò'),
              _buildStatItem(isGuestRole ? 'Cơ bản' : 'Mở rộng', 'Quyền'),
            ],
          ),
          const SizedBox(height: 24),
          if (isGuestRole) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PianoRentalScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGold,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: Text(
                  'Giỏ thuê đàn',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Guest dùng các tính năng cơ bản: Feed, Đăng bài, Chat, Thuê đàn.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: textMuted,
                fontSize: 12,
              ),
            ),
          ] else ...[
            // Quick Action Buttons (non-guest)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  icon: Icons.attach_money,
                  label: 'Affiliate',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AffiliateDashboardScreen(),
                      ),
                    );
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.wallet,
                  label: 'Ví',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tính năng Ví đang được phát triển',
                          style: GoogleFonts.inter(),
                        ),
                        backgroundColor: primaryGold,
                      ),
                    );
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.history,
                  label: 'Lịch sử',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tính năng Lịch sử đang được phát triển',
                          style: GoogleFonts.inter(),
                        ),
                        backgroundColor: primaryGold,
                      ),
                    );
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.settings,
                  label: 'Cài đặt',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Tính năng Cài đặt đang được phát triển',
                          style: GoogleFonts.inter(),
                        ),
                        backgroundColor: primaryGold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: cardAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryGold.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: primaryGold,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today,
              size: 60, color: textMuted.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Chưa có lịch đặt nào',
            style: GoogleFonts.inter(color: textMuted, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    Color statusColor;
    String statusText;

    switch (booking.status) {
      case 'confirmed':
        statusColor = const Color(0xFF4CAF50); // Green
        statusText = 'Đã đặt';
        break;
      case 'pending':
        statusColor = const Color(0xFFFFC107); // Amber
        statusText = 'Chờ duyệt';
        break;
      case 'cancelled':
        statusColor = const Color(0xFFF44336); // Red
        statusText = 'Đã hủy';
        break;
      case 'completed':
        statusColor = Colors.grey;
        statusText = 'Hoàn thành';
        break;
      default:
        statusColor = textMuted;
        statusText = booking.status;
    }

    final isCancelable =
        (booking.status == 'confirmed' || booking.status == 'pending') &&
            booking.startTime.isAfter(DateTime.now());

    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('HH:mm');
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Container(
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Piano Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              booking.pianoImage ?? 'https://via.placeholder.com/100',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: cardAlt,
                child: const Icon(Icons.music_note, color: textMuted),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Center: Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.pianoName ?? 'Unknown Piano',
                  style: GoogleFonts.inter(
                    color: textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${dateFormatter.format(booking.startTime)} • ${timeFormatter.format(booking.startTime)} - ${timeFormatter.format(booking.endTime)}',
                  style: GoogleFonts.inter(
                    color: textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormatter.format(booking.totalPrice),
                  style: GoogleFonts.inter(
                    color: primaryGold,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Right: Status Badge & Cancel Action
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.inter(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isCancelable) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _handleCancelBooking(booking.id),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      'Hủy',
                      style: GoogleFonts.inter(
                        color: Colors.redAccent,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Build Teacher Pending/Rejected Status View
  Widget _buildTeacherPendingOrRejected() {
    if (_teacherProfile == null) {
      return _buildTeacherSetupRequiredStatus();
    }

    final verificationStatus =
        _teacherProfile?['verification_status'] ?? 'pending';

    if (verificationStatus == 'pending') {
      return _buildPendingStatus();
    } else {
      // Rejected or other status
      return _buildRejectedStatus();
    }
  }

  Widget _buildTeacherSetupRequiredStatus() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.assignment_outlined,
                size: 64,
                color: Color(0xFFD4AF37),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Hoàn tất hồ sơ giáo viên',
              style: GoogleFonts.inter(
                color: textDark,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Bạn đã chọn role Teacher nhưng chưa nộp hồ sơ 3 bước.\nHãy hoàn tất để gửi duyệt.',
              style: GoogleFonts.inter(
                color: textMuted,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TeacherProfileSetupScreen(),
                    ),
                  );
                  if (!mounted) return;
                  _checkAuthAndFetch();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Bắt đầu hồ sơ 3 bước',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, size: 18),
              label: Text(
                'Đăng xuất',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: textMuted,
                side: BorderSide(color: borderLight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingStatus() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.schedule,
                size: 64,
                color: Color(0xFFD4AF37),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Hồ sơ đang chờ duyệt',
              style: GoogleFonts.inter(
                color: textDark,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Hồ sơ giáo viên của bạn đang được xem xét.\nChúng tôi sẽ thông báo kết quả trong vòng 72 giờ làm việc.',
              style: GoogleFonts.inter(
                color: textMuted,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _handleLogout(),
              icon: const Icon(Icons.logout, size: 20),
              label: Text(
                'Đăng xuất',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: cardLight,
                foregroundColor: textMuted,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: borderLight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedStatus() {
    final rejectedReason =
        _teacherProfile?['rejected_reason'] ?? 'Không đủ điều kiện';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.redAccent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.cancel_outlined,
                size: 64,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Hồ sơ không được duyệt',
              style: GoogleFonts.inter(
                color: textDark,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Lý do: $rejectedReason',
              style: GoogleFonts.inter(
                color: Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng liên hệ với chúng tôi để được hỗ trợ.',
              style: GoogleFonts.inter(
                color: textMuted,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _handleLogout(),
              icon: const Icon(Icons.logout, size: 20),
              label: Text(
                'Đăng xuất',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: cardLight,
                foregroundColor: textMuted,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: borderLight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
