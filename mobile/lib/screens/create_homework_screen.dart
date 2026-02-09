import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CreateHomeworkScreen extends StatefulWidget {
  final String studentName;
  final String studentLevel;

  const CreateHomeworkScreen({
    super.key,
    required this.studentName,
    required this.studentLevel,
  });

  @override
  State<CreateHomeworkScreen> createState() => _CreateHomeworkScreenState();
}

class _CreateHomeworkScreenState extends State<CreateHomeworkScreen> {
  int _selectedExerciseType = 0; // 0: Finger, 1: Song, 2: Note Reading, 3: Rhythm
  double _bpm = 80.0;
  int _repetitions = 10;
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  bool _hasSheetMusic = false;
  bool _hasDemoVideo = false;

  final List<ExerciseType> _exerciseTypes = [
    ExerciseType(emoji: '👆', label: 'Bài luyện ngón'),
    ExerciseType(emoji: '🎵', label: 'Bài nhạc'),
    ExerciseType(emoji: '🎼', label: 'Đọc nốt'),
    ExerciseType(emoji: '⏱', label: 'Nhịp điệu'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // 1. STICKY HEADER
            _buildHeader(),

            // 2. SCROLLABLE CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Exercise Type
                    _buildExerciseTypeSection(),
                    const SizedBox(height: 24),

                    // Section 2: Content Input
                    _buildContentInputSection(),
                    const SizedBox(height: 24),

                    // Section 3: Goal Settings
                    _buildGoalSettingsSection(),
                    const SizedBox(height: 24),

                    // Section 4: AI Suggestion
                    _buildAISuggestionCard(),

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
        color: const Color(0xFF1E1E1E),
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
                color: const Color(0xFF2E2E2E),
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
              'Tạo bài tập cho ${widget.studentName}',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          // Help Icon
          GestureDetector(
            onTap: _showHelpDialog,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E2E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.help_outline,
                color: Color(0xFFD4AF37),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  // SECTION 1: EXERCISE TYPE
  Widget _buildExerciseTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn loại bài tập',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: _exerciseTypes.length,
          itemBuilder: (context, index) {
            final type = _exerciseTypes[index];
            final isSelected = _selectedExerciseType == index;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedExerciseType = index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFB8941F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : const Color(0xFF2E2E2E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFD4AF37)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      type.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        type.label,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: (100 + index * 50).ms, duration: 400.ms);
          },
        ),
      ],
    ).animate().fadeIn(delay: 100.ms, duration: 500.ms);
  }

  // SECTION 2: CONTENT INPUT
  Widget _buildContentInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tải nội dung bài tập',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Button A: Upload Sheet Music
            Expanded(
              child: _buildUploadButton(
                icon: Icons.upload_file,
                label: 'Tải bản nhạc',
                sublabel: 'PDF/IMG',
                isUploaded: _hasSheetMusic,
                onTap: _handleUploadSheetMusic,
              ),
            ),
            const SizedBox(width: 12),
            // Button B: Record Demo
            Expanded(
              child: _buildUploadButton(
                icon: Icons.videocam,
                label: 'Quay mẫu',
                sublabel: 'Video/Audio',
                isUploaded: _hasDemoVideo,
                onTap: _handleRecordDemo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 14,
              color: Colors.grey[500],
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Đính kèm sheet nhạc hoặc video hướng dẫn',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms);
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required String sublabel,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded
                ? const Color(0xFFD4AF37)
                : const Color(0xFFD4AF37).withOpacity(0.3),
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
            style: isUploaded ? BorderStyle.solid : BorderStyle.none,
          ),
        ),
        child: CustomPaint(
          painter: isUploaded
              ? null
              : DashedBorderPainter(
                  color: const Color(0xFFD4AF37).withOpacity(0.5),
                  strokeWidth: 2,
                  dashLength: 8,
                  gapLength: 4,
                ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUploaded
                        ? const Color(0xFFD4AF37).withOpacity(0.2)
                        : const Color(0xFF2E2E2E),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUploaded ? Icons.check_circle : icon,
                    color: const Color(0xFFD4AF37),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  sublabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // SECTION 3: GOAL SETTINGS
  Widget _buildGoalSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thiết lập mục tiêu',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        
        // Speed (BPM) Slider
        _buildBPMSlider(),
        const SizedBox(height: 24),
        
        // Repetitions Stepper
        _buildRepetitionsStepper(),
        const SizedBox(height: 24),
        
        // Deadline Picker
        _buildDeadlinePicker(),
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms);
  }

  Widget _buildBPMSlider() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
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
                'Tốc độ (BPM)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.5),
                  ),
                ),
                child: Text(
                  '${_bpm.toInt()}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFFD4AF37),
              inactiveTrackColor: const Color(0xFF2E2E2E),
              thumbColor: const Color(0xFFD4AF37),
              overlayColor: const Color(0xFFD4AF37).withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 6,
            ),
            child: Slider(
              value: _bpm,
              min: 60,
              max: 120,
              divisions: 60,
              onChanged: (value) {
                setState(() => _bpm = value);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '60',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                '120',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRepetitionsStepper() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Số lần luyện',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Row(
            children: [
              // Minus Button
              GestureDetector(
                onTap: () {
                  if (_repetitions > 1) {
                    setState(() => _repetitions--);
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2E2E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Value
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.5),
                  ),
                ),
                child: Text(
                  '$_repetitions',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Plus Button
              GestureDetector(
                onTap: () {
                  if (_repetitions < 99) {
                    setState(() => _repetitions++);
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2E2E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlinePicker() {
    return GestureDetector(
      onTap: _selectDeadline,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
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
                Icons.calendar_today,
                color: Color(0xFFD4AF37),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hạn hoàn thành',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatVietnameseDate(_deadline),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFD4AF37),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // SECTION 4: AI SUGGESTION
  Widget _buildAISuggestionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2E2416),
            const Color(0xFF1E1E1E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
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
                child: const Text(
                  '✨',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Gợi ý',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Tạo nhanh',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Bài tập phù hợp Level ${widget.studentLevel}: Chơi 1 bài trong 30 ngày.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _applyAISuggestion,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: Text(
                'Áp dụng gợi ý này',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD4AF37),
                side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms).scale(begin: const Offset(0.95, 0.95));
  }

  // FOOTER ACTIONS
  Widget _buildFooterActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
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
          // Button 1: Save Draft
          Expanded(
            child: OutlinedButton(
              onPressed: _saveDraft,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD4AF37),
                side: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Lưu nháp',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Button 2: Send Assignment
          Expanded(
            flex: 2,
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
                onPressed: _sendAssignment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Gửi bài tập',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  // HELPER METHODS
  String _formatVietnameseDate(DateTime date) {
    const weekdayNames = [
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'Chủ nhật'
    ];
    
    final weekday = weekdayNames[date.weekday - 1];
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    
    return '$weekday, $day/$month';
  }

  void _handleUploadSheetMusic() async {
    // Simulate file picker
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _hasSheetMusic = !_hasSheetMusic);
    
    if (_hasSheetMusic && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã tải bản nhạc thành công',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1E1E1E),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleRecordDemo() async {
    // Simulate video recording
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _hasDemoVideo = !_hasDemoVideo);
    
    if (_hasDemoVideo && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã lưu video mẫu thành công',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1E1E1E),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _selectDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1E1E1E),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _deadline) {
      setState(() => _deadline = picked);
    }
  }

  void _applyAISuggestion() {
    setState(() {
      _selectedExerciseType = 1; // Bài nhạc
      _bpm = 70.0;
      _repetitions = 15;
      _deadline = DateTime.now().add(const Duration(days: 30));
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã áp dụng gợi ý AI',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFFD4AF37)),
            const SizedBox(width: 12),
            Text(
              'Đã lưu bản nháp',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sendAssignment() {
    if (!_hasSheetMusic && !_hasDemoVideo) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vui lòng tải bản nhạc hoặc video mẫu',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: Colors.red[900],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFFD4AF37), size: 28),
            const SizedBox(width: 12),
            Text(
              'Thành công',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Đã gửi bài tập cho ${widget.studentName}',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
            ),
            child: Text(
              'OK',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Hướng dẫn tạo bài tập',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem('1. Chọn loại bài tập phù hợp với mục tiêu'),
              _buildHelpItem('2. Tải sheet nhạc hoặc quay video hướng dẫn'),
              _buildHelpItem('3. Cài đặt tốc độ BPM và số lần luyện'),
              _buildHelpItem('4. Chọn hạn hoàn thành'),
              _buildHelpItem('5. Sử dụng AI Gợi ý để tạo nhanh'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Đóng',
              style: GoogleFonts.inter(color: const Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFFD4AF37),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Dashed Border
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(16),
      ));

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final segment = pathMetric.extractPath(
          distance,
          distance + dashLength,
        );
        canvas.drawPath(segment, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Model
class ExerciseType {
  final String emoji;
  final String label;

  ExerciseType({
    required this.emoji,
    required this.label,
  });
}
