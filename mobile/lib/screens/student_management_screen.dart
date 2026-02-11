import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'student_detail_screen.dart';
import 'create_homework_screen.dart';
import 'messages_screen.dart';
import 'chat_detail_screen.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() =>
      _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Light Mode Palette
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color backgroundLight = Color(0xFFF7F7F7);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardAlt = Color(0xFFF1F1F1);
  static const Color borderLight = Color(0xFFE6E6E6);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B6B6B);

  // Mock data
  final List<Student> _students = [
    Student(
      name: 'Minh Anh',
      avatar: 'https://i.pravatar.cc/150?img=1',
      level: 'Intermediate',
      mode: 'Online',
      progressPercent: 78,
      lastPractice: '2 giờ trước',
      lastScore: 92,
      nextSession: 'Thứ 6 • 19:00',
    ),
    Student(
      name: 'Hải Đăng',
      avatar: 'https://i.pravatar.cc/150?img=12',
      level: 'Beginner',
      mode: 'Offline',
      progressPercent: 45,
      lastPractice: '1 ngày trước',
      lastScore: 85,
      nextSession: 'Thứ 7 • 10:00',
    ),
    Student(
      name: 'Thu Hằng',
      avatar: 'https://i.pravatar.cc/150?img=5',
      level: 'Advanced',
      mode: 'Online',
      progressPercent: 92,
      lastPractice: '30 phút trước',
      lastScore: 98,
      nextSession: 'Thứ 5 • 20:30',
    ),
    Student(
      name: 'Bảo Trâm',
      avatar: 'https://i.pravatar.cc/150?img=9',
      level: 'Intermediate',
      mode: 'Offline',
      progressPercent: 65,
      lastPractice: '4 giờ trước',
      lastScore: 88,
      nextSession: 'CN • 15:00',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String _searchQuery = '';
  String _selectedLevel = 'Tất cả';
  String _selectedMode = 'Tất cả';
  String _selectedSort = 'Tên A-Z';

  List<Student> get _filteredStudents {
    final query = _searchQuery.trim().toLowerCase();
    final students = _students.where((student) {
      final matchesSearch =
          query.isEmpty || student.name.toLowerCase().contains(query);
      final matchesLevel =
          _selectedLevel == 'Tất cả' || student.level == _selectedLevel;
      final matchesMode =
          _selectedMode == 'Tất cả' || student.mode == _selectedMode;
      return matchesSearch && matchesLevel && matchesMode;
    }).toList();

    if (_selectedSort == 'Tên Z-A') {
      students.sort((a, b) => b.name.compareTo(a.name));
    } else {
      students.sort((a, b) => a.name.compareTo(b.name));
    }
    return students;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    _buildAIInsightSection(),
                    const SizedBox(height: 20),
                    _buildQuickStats(),
                    const SizedBox(height: 20),
                    _buildStudentList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. HEADER
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cardAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quản lý học viên',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Theo dõi tiến độ • Lịch học • Học phí',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              _buildHeaderIcon(Icons.search, _showSearchSheet),
              const SizedBox(width: 8),
              _buildHeaderIcon(Icons.filter_list, _showFilterSheet),
              const SizedBox(width: 8),
              _buildHeaderIcon(
                Icons.chat_bubble_outline,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MessagesScreen(),
                    ),
                  );
                },
                badge: 3,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap, {int? badge}) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
          ),
        ),
        if (badge != null)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$badge',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  // TABS
  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: cardLight,
      child: TabBar(
        controller: _tabController,
        indicatorColor: primaryGold,
        indicatorWeight: 3,
        labelColor: primaryGold,
        unselectedLabelColor: textMuted,
        labelStyle:
            GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal),
        tabs: const [
          Tab(text: 'Đang học'),
          Tab(text: 'Chờ xếp lịch'),
          Tab(text: 'Đã kết thúc'),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  // 2. AI INSIGHT SECTION
  Widget _buildAIInsightSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFFD4AF37),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI gợi ý',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '5 học viên đang chậm nhịp ➜ đề xuất bài luyện BPM 60 trong 7 ngày',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textDark,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '✓ Đã áp dụng gợi ý AI!',
                      style: GoogleFonts.inter(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: const Color(0xFFD4AF37),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Text(
                'Áp dụng',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .slideX(begin: -0.1, end: 0);
  }

  // 3. QUICK STATS
  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tổng quan',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatChip('👤', 'Học viên hoạt động', '24'),
              _buildStatChip('📅', 'Buổi hôm nay', '6'),
              _buildStatChip('✅', 'Tỉ lệ hoàn tất', '98%'),
              _buildStatChip('⚠', 'Cần nhắc nhở', '5', isWarning: true),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms);
  }

  Widget _buildStatChip(String emoji, String label, String value,
      {bool isWarning = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning
              ? Colors.orange.withOpacity(0.5)
              : const Color(0xFFD4AF37).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isWarning ? Colors.orange : const Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // 4. STUDENT LIST
  // 4. STUDENT LIST
  Widget _buildStudentList() {
    final filteredStudents = _filteredStudents;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Danh sách học viên',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            Text(
              ' học viên',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (filteredStudents.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: BoxDecoration(
              color: cardLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderLight),
            ),
            child: Column(
              children: [
                const Icon(Icons.search_off,
                    color: Color(0xFFD4AF37), size: 30),
                const SizedBox(height: 10),
                Text(
                  'Không tìm thấy học viên phù hợp',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bạn có thể đổi bộ lọc hoặc từ khóa tìm kiếm.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredStudents.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildStudentCard(filteredStudents[index], index);
            },
          ),
      ],
    );
  }

  Widget _buildStudentCard(Student student, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          StudentDetailScreen(
                        studentName: student.name,
                        studentAvatar: student.avatar,
                        level: student.level,
                        nextLesson: student.nextSession,
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(
                            position: offsetAnimation, child: child);
                      },
                    ),
                  );
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.5),
                      width: 2,
                    ),
                    image: DecorationImage(
                      image: NetworkImage(student.avatar),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildBadge(
                          student.level,
                          student.level == 'Beginner'
                              ? Colors.blue
                              : student.level == 'Intermediate'
                                  ? Colors.brown
                                  : Colors.purple,
                        ),
                        const SizedBox(width: 6),
                        _buildBadge(
                          student.mode,
                          student.mode == 'Online'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: textMuted),
                onPressed: () => _showStudentMenu(student),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến độ tuần',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: textMuted,
                ),
              ),
              Text(
                '${student.progressPercent}%',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: student.progressPercent / 100,
              minHeight: 8,
              backgroundColor: cardAlt,
              valueColor: AlwaysStoppedAnimation<Color>(
                student.progressPercent >= 80
                    ? const Color(0xFFD4AF37)
                    : student.progressPercent >= 50
                        ? Colors.blue
                        : Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Info Grid
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Luyện tập gần nhất',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student.lastPractice,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFD4AF37), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${student.lastScore}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  color: Color(0xFFD4AF37), size: 14),
              const SizedBox(width: 6),
              Text(
                'Buổi tiếp theo: ${student.nextSession}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          studentName: student.name,
                          studentAvatar: student.avatar,
                          level: student.level,
                          nextLesson: student.nextSession,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.message, size: 16),
                  label: Text(
                    'Nhắn tin',
                    style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textDark,
                    side: const BorderSide(color: borderLight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateHomeworkScreen(
                          studentName: student.name,
                          studentLevel: student.level,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.assignment, size: 16),
                  label: Text(
                    'Giao bài',
                    style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          StudentDetailScreen(
                        studentName: student.name,
                        studentAvatar: student.avatar,
                        level: student.level,
                        nextLesson: student.nextSession,
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOut;
                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(
                            position: offsetAnimation, child: child);
                      },
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD4AF37),
                  side: const BorderSide(color: Color(0xFFD4AF37)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                child: const Icon(Icons.trending_up, size: 18),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (400 + index * 100).ms, duration: 500.ms)
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  void _showSearchSheet() {
    _searchController.text = _searchQuery;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tìm kiếm học viên',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Nhập tên học viên...',
                hintStyle: GoogleFonts.inter(color: textMuted),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFD4AF37)),
                filled: true,
                fillColor: cardAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                      Navigator.pop(ctx);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textMuted,
                      side: const BorderSide(color: borderLight),
                    ),
                    child: Text(
                      'Xóa',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = _searchController.text.trim();
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                    ),
                    child: Text(
                      'Áp dụng',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    final levels = ['Tất cả', 'Beginner', 'Intermediate', 'Advanced'];
    final modes = ['Tất cả', 'Online', 'Offline'];
    final sorts = ['Tên A-Z', 'Tên Z-A'];

    String tempLevel = _selectedLevel;
    String tempMode = _selectedMode;
    String tempSort = _selectedSort;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Lọc học viên',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Trình độ',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: levels.map((level) {
                  return _buildSelectableChip(
                    label: level,
                    selected: tempLevel == level,
                    onTap: () => setModalState(() => tempLevel = level),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Text(
                'Trạng thái',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: modes.map((mode) {
                  return _buildSelectableChip(
                    label: mode,
                    selected: tempMode == mode,
                    onTap: () => setModalState(() => tempMode = mode),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Text(
                'Sắp xếp',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sorts.map((sort) {
                  return _buildSelectableChip(
                    label: sort,
                    selected: tempSort == sort,
                    onTap: () => setModalState(() => tempSort = sort),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedLevel = 'Tất cả';
                          _selectedMode = 'Tất cả';
                          _selectedSort = 'Tên A-Z';
                        });
                        Navigator.pop(ctx);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textMuted,
                        side: const BorderSide(color: borderLight),
                      ),
                      child: Text(
                        'Đặt lại',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedLevel = tempLevel;
                          _selectedMode = tempMode;
                          _selectedSort = tempSort;
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                      ),
                      child: Text(
                        'Áp dụng',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectableChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFD4AF37).withOpacity(0.14) : cardAlt,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFFD4AF37) : borderLight,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? const Color(0xFFB39129) : textMuted,
          ),
        ),
      ),
    );
  }

  void _showStudentMenu(Student student) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFFD4AF37)),
              title: Text('Chỉnh sửa thông tin',
                  style: GoogleFonts.inter(color: textDark)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Color(0xFFD4AF37)),
              title: Text('Xem lịch học',
                  style: GoogleFonts.inter(color: textDark)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: Color(0xFFD4AF37)),
              title: Text('Quản lý học phí',
                  style: GoogleFonts.inter(color: textDark)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: Text('Tạm dừng học',
                  style: GoogleFonts.inter(color: Colors.red)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // 5. BOTTOM NAV
}

// Model
class Student {
  final String name;
  final String avatar;
  final String level;
  final String mode;
  final int progressPercent;
  final String lastPractice;
  final int lastScore;
  final String nextSession;

  Student({
    required this.name,
    required this.avatar,
    required this.level,
    required this.mode,
    required this.progressPercent,
    required this.lastPractice,
    required this.lastScore,
    required this.nextSession,
  });
}
