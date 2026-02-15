import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/supabase_service.dart';

/// Debug screen for admin actions (temporary for testing)
/// Access: Add a button in ProfileScreen or navigate directly
class AdminDebugScreen extends StatefulWidget {
  const AdminDebugScreen({super.key});

  @override
  State<AdminDebugScreen> createState() => _AdminDebugScreenState();
}

class _AdminDebugScreenState extends State<AdminDebugScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;
  String _statusMessage = '';
  List<Map<String, dynamic>> _teachers = [];
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    if (_supabaseService.currentUser == null) {
      setState(() {
        _teachers = [];
        _isLoading = false;
        _statusMessage = 'Bạn cần đăng nhập để dùng Admin Debug';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang tải danh sách...';
    });

    try {
      print('🔍 Fetching all teacher profiles...');
      final teachers = await _supabaseService.getAllTeacherProfiles();
      print('✅ Fetched ${teachers.length} teachers');

      if (teachers.isNotEmpty) {
        for (var teacher in teachers) {
          print(
              '   - ${teacher['full_name']} (${teacher['verification_status']})');
        }
      } else {
        print('⚠️ No teachers found in database');
      }

      setState(() {
        _teachers = teachers;
        _isLoading = false;
        _statusMessage = teachers.isEmpty
            ? 'Không có giáo viên nào trong database'
            : 'Tải ${teachers.length} giáo viên thành công';
      });
    } catch (e) {
      print('❌ Error loading teachers: $e');
      setState(() {
        _isLoading = false;
        _statusMessage = 'Lỗi: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lỗi khi tải danh sách: $e',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang kiểm tra kết nối...';
    });

    try {
      final user = _supabaseService.currentUser;
      final debugLines = <String>[];

      debugLines.add('🔐 Current User:');
      if (user != null) {
        debugLines.add('   ID: ${user.id}');
        debugLines.add('   Email: ${user.email}');
      } else {
        debugLines.add('   ❌ No user logged in');
      }

      debugLines.add('\n📋 My Teacher Profile:');
      final myProfile = await _supabaseService.getTeacherProfile();
      if (myProfile != null) {
        debugLines.add('   ✅ Found');
        debugLines.add('   Name: ${myProfile['full_name']}');
        debugLines.add('   Status: ${myProfile['verification_status']}');
      } else {
        debugLines.add('   ❌ No teacher profile found for current user');
      }

      debugLines.add('\n📊 All Teacher Profiles Query:');
      final allProfiles = await _supabaseService.getAllTeacherProfiles();
      debugLines.add('   Count: ${allProfiles.length}');

      if (allProfiles.isEmpty) {
        debugLines.add('   ⚠️ WARNING: Database returned 0 profiles');
        debugLines.add('   Possible causes:');
        debugLines.add('   - No teacher profiles in database');
        debugLines.add('   - RLS policy blocking query');
        debugLines.add('   - Wrong table name');
      } else {
        debugLines.add('   ✅ Found profiles:');
        for (var profile in allProfiles) {
          debugLines.add(
              '      - ${profile['full_name']} (${profile['verification_status']})');
        }
      }

      final debugText = debugLines.join('\n');
      print('\n$debugText\n');

      setState(() {
        _debugInfo = debugText;
        _isLoading = false;
        _statusMessage = 'Kiểm tra hoàn tất';
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: Text(
              'Debug Info',
              style: GoogleFonts.inter(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Text(
                debugText,
                style: GoogleFonts.robotoMono(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Đóng',
                    style: GoogleFonts.inter(color: const Color(0xFFD4AF37))),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('❌ Error in test connection: $e');
      setState(() {
        _isLoading = false;
        _statusMessage = 'Lỗi: $e';
        _debugInfo = 'Error: $e';
      });
    }
  }

  Future<void> _approveAll() async {
    if (_supabaseService.currentUser == null) {
      setState(() {
        _statusMessage = 'Bạn cần đăng nhập để duyệt hồ sơ';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang approve...';
    });

    final result = await _supabaseService.approveAllPendingTeachers();

    setState(() {
      _isLoading = false;
      _statusMessage = result['message'];
    });

    if (result['success']) {
      // Reload list
      await _loadTeachers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ ${result['message']}',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        _teachers.where((t) => t['verification_status'] == 'pending').length;
    final approvedCount =
        _teachers.where((t) => t['verification_status'] == 'approved').length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          'Admin Debug',
          style: GoogleFonts.inter(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFD4AF37)),
            onPressed: _loadTeachers,
            tooltip: 'Tải lại',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            )
          : Column(
              children: [
                // Status Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                              'Tổng', '${_teachers.length}', Colors.white),
                          _buildStatItem(
                              'Chờ duyệt', '$pendingCount', Colors.orange),
                          _buildStatItem(
                              'Đã duyệt', '$approvedCount', Colors.green),
                        ],
                      ),
                      if (_statusMessage.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFF2E2E2E)),
                        const SizedBox(height: 16),
                        Text(
                          _statusMessage,
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),

                // Test Connection Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _testConnection,
                      icon: const Icon(Icons.bug_report, size: 20),
                      label: Text(
                        'Kiểm tra kết nối & Debug',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD4AF37),
                        side: const BorderSide(
                          color: Color(0xFFD4AF37),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Approve Button
                if (pendingCount > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _approveAll,
                        icon: const Icon(Icons.check_circle, size: 24),
                        label: Text(
                          'Duyệt tất cả $pendingCount giáo viên',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Teacher List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _teachers.length,
                    itemBuilder: (context, index) {
                      final teacher = _teachers[index];
                      return _buildTeacherCard(teacher);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
    final name = teacher['full_name'] ?? 'Unknown';
    final status = teacher['verification_status'] ?? 'unknown';
    final specializations = teacher['specializations'] as List?;

    Color statusColor;
    String statusText;

    switch (status) {
      case 'approved':
        statusColor = Colors.green;
        statusText = 'Đã duyệt';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Chờ duyệt';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Từ chối';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2E2E2E),
              image: teacher['avatar_url'] != null
                  ? DecorationImage(
                      image: NetworkImage(teacher['avatar_url']),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: teacher['avatar_url'] == null
                ? const Icon(Icons.person, color: Colors.white54, size: 24)
                : null,
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (specializations != null && specializations.isNotEmpty)
                  Text(
                    specializations.join(', '),
                    style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.5)),
            ),
            child: Text(
              statusText,
              style: GoogleFonts.inter(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
