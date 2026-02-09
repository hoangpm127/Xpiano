import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'create_homework_screen.dart';
import 'chat_detail_screen.dart';

class StudentDetailScreen extends StatefulWidget {
  final String studentName;
  final String studentAvatar;
  final String level;
  final String nextLesson;

  const StudentDetailScreen({
    super.key,
    required this.studentName,
    required this.studentAvatar,
    required this.level,
    required this.nextLesson,
  });

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Light Mode Palette
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color backgroundLight = Color(0xFFF7F7F7);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardAlt = Color(0xFFF1F1F1);
  static const Color borderLight = Color(0xFFE6E6E6);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B6B6B);

  // Mock data
  final int _recentScore = 92;
  final int _streakDays = 12;
  final double _weekProgress = 0.70;
  final String _currentPiece = 'Canon in D — đoạn 1';
  final String _goal = 'Chơi 1 bài trong 30 ngày';

  final List<TeacherNote> _teacherNotes = [
    TeacherNote(
      date: '5/02/2026',
      content: 'Cần giữ nhịp tay trái đều hơn, đặc biệt ở phần chậm',
    ),
    TeacherNote(
      date: '2/02/2026',
      content: 'Tư thế ngồi đã tốt hơn! Tiếp tục duy trì',
    ),
    TeacherNote(
      date: '30/01/2026',
      content: 'Nâng cao độ chính xác khi đọc nốt nhạc',
    ),
  ];

  final List<LessonHistoryItem> _lessonHistory = [
    LessonHistoryItem(
      date: '07/02/2026',
      time: '19:30 - 20:30',
      mode: 'Online 1-1',
      topic: 'Luyện nhịp tay trái + đọc nốt',
      result: 'Hoàn thành tốt',
      score: 92,
    ),
    LessonHistoryItem(
      date: '03/02/2026',
      time: '19:30 - 20:30',
      mode: 'Offline',
      topic: 'Canon in D - đoạn 1',
      result: 'Cần tập thêm pedal',
      score: 86,
    ),
    LessonHistoryItem(
      date: '31/01/2026',
      time: '20:00 - 21:00',
      mode: 'Online 1-1',
      topic: 'Bài tập ngón Hanon 1-3',
      result: 'Tiến bộ rõ',
      score: 90,
    ),
  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // 1. STICKY HEADER
            _buildHeader(),

            // 2. SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildStudentIdentity(),
                    const SizedBox(height: 20),
                    _buildGoalCard(),
                    const SizedBox(height: 20),
                    _buildQuickStats(),
                    const SizedBox(height: 20),
                    _buildTabNavigation(),
                    const SizedBox(height: 20),
                    _buildTabContent(),
                    const SizedBox(height: 100), // Space for sticky footer
                  ],
                ),
              ),
            ),

            // 3. STICKY FOOTER
            _buildFooterActions(),
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
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
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
          // Title
          Expanded(
            child: Text(
              'Hồ sơ học viên',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
          ),
          // Menu Icon
          GestureDetector(
            onTap: _showMenu,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.more_vert,
                color: Color(0xFFD4AF37),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  // 2. STUDENT IDENTITY
  Widget _buildStudentIdentity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD4AF37),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                widget.studentAvatar,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: cardAlt,
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFFD4AF37),
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  widget.studentName,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                // Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎖', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        widget.level,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Status
                Text(
                  'Học viên đang theo học',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 500.ms)
        .slideX(begin: -0.1, end: 0);
  }

  // 3. GOAL CARD
  Widget _buildGoalCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD4AF37),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Target Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flag_circle,
                color: Color(0xFFD4AF37),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            // Goal Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mục tiêu',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _goal,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .scale(begin: const Offset(0.95, 0.95));
  }

  // 4. QUICK STATS ROW
  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Card 1: Recent Score
          Expanded(
            child: _buildStatCard(
              label: 'Điểm gần nhất',
              value: '$_recentScore',
              subtitle: 'Bài gần nhất',
              icon: Icons.star,
              delay: 300,
            ),
          ),
          const SizedBox(width: 12),
          // Card 2: Streak
          Expanded(
            child: _buildStatCard(
              label: 'Chuỗi luyện tập',
              value: '$_streakDays ngày',
              subtitle: 'Giữ streak để tiến bộ',
              icon: Icons.local_fire_department,
              delay: 400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required int delay,
  }) {
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
          Row(
            children: [
              Icon(icon, color: const Color(0xFFD4AF37), size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: textMuted,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delay.ms, duration: 500.ms)
        .slideY(begin: 0.1, end: 0);
  }

  // 5. TAB NAVIGATION
  Widget _buildTabNavigation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFFD4AF37),
        indicatorWeight: 3,
        labelColor: const Color(0xFFD4AF37),
        unselectedLabelColor: textMuted,
        labelStyle:
            GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.normal),
        tabs: const [
          Tab(text: 'Tiến độ'),
          Tab(text: 'Lịch sử'),
          Tab(text: 'Ghi chú'),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms);
  }

  // 6. TAB CONTENT
  Widget _buildTabContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          switch (_tabController.index) {
            case 1:
              return _buildLessonHistoryTab();
            case 2:
              return _buildNotesTab();
            default:
              return _buildProgressTab();
          }
        },
      ),
    );
  }

  Widget _buildProgressTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekly Progress Bar
        _buildWeeklyProgress(),
        const SizedBox(height: 24),
        // Current Piece
        _buildCurrentPiece(),
        const SizedBox(height: 24),
        // Teacher Notes Section
        _buildTeacherNotes(),
      ],
    );
  }

  Widget _buildLessonHistoryTab() {
    return Column(
      children: _lessonHistory.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Container(
          margin: EdgeInsets.only(
              bottom: index == _lessonHistory.length - 1 ? 0 : 12),
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.date,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      'Điểm ${item.score}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB39129),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.topic,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule,
                      size: 15, color: Color(0xFFD4AF37)),
                  const SizedBox(width: 6),
                  Text(
                    item.time,
                    style: GoogleFonts.inter(fontSize: 13, color: textMuted),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.videocam_outlined,
                      size: 15, color: Color(0xFFD4AF37)),
                  const SizedBox(width: 6),
                  Text(
                    item.mode,
                    style: GoogleFonts.inter(fontSize: 13, color: textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.result,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (100 + index * 70).ms).slideY(
              begin: 0.12,
              duration: 300.ms,
            );
      }).toList(),
    );
  }

  Widget _buildNotesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ghi chú riêng tư',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showAddNoteDialog,
              icon: const Icon(Icons.add, size: 16),
              label: Text(
                'Thêm',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._teacherNotes.asMap().entries.map((entry) {
          final index = entry.key;
          final note = entry.value;
          return Container(
            margin: EdgeInsets.only(
                bottom: index == _teacherNotes.length - 1 ? 0 : 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.date,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  note.content,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: textDark,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (80 + index * 70).ms);
        }),
      ],
    );
  }

  Widget _buildWeeklyProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến độ tuần này',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              Text(
                '${(_weekProgress * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _weekProgress,
              minHeight: 12,
              backgroundColor: cardAlt,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 500.ms)
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildCurrentPiece() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.music_note,
              color: Color(0xFFD4AF37),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bài đang luyện',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentPiece,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 500.ms)
        .slideX(begin: -0.1, end: 0);
  }

  Widget _buildTeacherNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Add Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ghi chú của giáo viên',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
            GestureDetector(
              onTap: _showAddNoteDialog,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Horizontal Scrollable Notes
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _teacherNotes.length,
            itemBuilder: (context, index) {
              final note = _teacherNotes[index];
              return Container(
                width: 240,
                margin: EdgeInsets.only(
                  right: index < _teacherNotes.length - 1 ? 12 : 0,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.edit_note,
                          color: const Color(0xFFD4AF37),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          note.date,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Text(
                        note.content,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: textDark,
                          height: 1.4,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: (800 + index * 100).ms, duration: 500.ms);
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 800.ms, duration: 500.ms);
  }

  // 7. FOOTER ACTIONS
  Widget _buildFooterActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardLight,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Button 1: Message
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatDetailScreen(
                      studentName: widget.studentName,
                      studentAvatar: widget.studentAvatar,
                      level: widget.level,
                      nextLesson: widget.nextLesson,
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD4AF37),
                side: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.message_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Nhắn tin',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Button 2: Create Assignment
          Expanded(
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
                      builder: (context) => CreateHomeworkScreen(
                        studentName: widget.studentName,
                        studentLevel: widget.level,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.assignment_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Tạo bài tập',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 900.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  // HELPER METHODS
  void _showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuOption(Icons.edit, 'Chỉnh sửa hồ sơ', () {}),
            _buildMenuOption(Icons.calendar_today, 'Xem lịch học', () {}),
            _buildMenuOption(Icons.attach_money, 'Quản lý học phí', () {}),
            _buildMenuOption(Icons.pause_circle_outline, 'Tạm dừng học', () {}),
            const Divider(color: borderLight, height: 32),
            _buildMenuOption(
              Icons.delete_outline,
              'Xóa học viên',
              () {},
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(IconData icon, String label, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFFD4AF37),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: isDestructive ? Colors.red : textDark,
          fontSize: 15,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _showAddNoteDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardLight,
        title: Text(
          'Thêm ghi chú',
          style: GoogleFonts.inter(
            color: textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: GoogleFonts.inter(color: textDark),
          decoration: InputDecoration(
            hintText: 'Nhập nội dung ghi chú...',
            hintStyle: GoogleFonts.inter(color: textMuted),
            filled: true,
            fillColor: cardAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: GoogleFonts.inter(color: textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newNote = controller.text.trim();
              if (newNote.isEmpty) {
                Navigator.pop(context);
                return;
              }
              setState(() {
                _teacherNotes.insert(
                  0,
                  TeacherNote(
                    date:
                        '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
                    content: newNote,
                  ),
                );
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Đã lưu ghi chú',
                    style: GoogleFonts.inter(color: textDark),
                  ),
                  backgroundColor: cardLight,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
            ),
            child: Text(
              'Lưu',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// Model
class LessonHistoryItem {
  final String date;
  final String time;
  final String mode;
  final String topic;
  final String result;
  final int score;

  LessonHistoryItem({
    required this.date,
    required this.time,
    required this.mode,
    required this.topic,
    required this.result,
    required this.score,
  });
}

class TeacherNote {
  final String date;
  final String content;

  TeacherNote({
    required this.date,
    required this.content,
  });
}
