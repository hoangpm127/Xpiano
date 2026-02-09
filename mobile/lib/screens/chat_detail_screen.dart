import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'create_homework_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final String studentName;
  final String studentAvatar;
  final String level;
  final String nextLesson;

  const ChatDetailScreen({
    super.key,
    required this.studentName,
    required this.studentAvatar,
    required this.level,
    required this.nextLesson,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;

  // Light Mode Palette
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color backgroundLight = Color(0xFFF7F7F7);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardAlt = Color(0xFFF1F1F1);
  static const Color borderLight = Color(0xFFE6E6E6);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B6B6B);

  // Mock messages
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Cô ơi, đoạn tay trái em hay lệch nhịp.',
      isTeacher: false,
      time: '09:10',
      type: MessageType.text,
    ),
    ChatMessage(
      text: 'Em thử tập chậm 60 BPM trước nhé. Nghe cô gửi mẫu này.',
      isTeacher: true,
      time: '09:12',
      type: MessageType.text,
    ),
    ChatMessage(
      text: '',
      isTeacher: true,
      time: '09:12',
      type: MessageType.audio,
      duration: '0:45',
    ),
    ChatMessage(
      text: 'Dạ em cảm ơn cô! 🙏',
      isTeacher: false,
      time: '09:15',
      type: MessageType.text,
    ),
  ];

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            _buildTopBar(),

            // NEXT LESSON REMINDER
            _buildNextLessonReminder(),

            // MESSAGES
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index], index);
                },
              ),
            ),

            // QUICK ACTIONS
            if (!_isRecording) _buildQuickActionsRow(),

            // RECORDING STATE
            if (_isRecording) _buildRecordingPanel(),

            // INPUT FIELD
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  // TOP BAR
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cardAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFFD4AF37),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.5),
                width: 2,
              ),
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
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name & Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.studentName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    widget.level,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // More Options
          GestureDetector(
            onTap: _showOptionsMenu,
            child: Container(
              padding: const EdgeInsets.all(8),
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

  // NEXT LESSON REMINDER
  Widget _buildNextLessonReminder() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.15),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.push_pin,
            color: Color(0xFFD4AF37),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Buổi học tiếp theo: ${widget.nextLesson}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textDark,
              ),
            ),
          ),
          TextButton(
            onPressed: _editNextLesson,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: const Color(0xFFD4AF37).withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Sửa',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD4AF37),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  // MESSAGE BUBBLE
  Widget _buildMessageBubble(ChatMessage message, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            message.isTeacher ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isTeacher) ...[
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: message.isTeacher
                  ? const LinearGradient(
                      colors: [
                        Color(0xFFFFE9B5),
                        Color(0xFFFFD77A),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: message.isTeacher ? null : cardAlt,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: message.isTeacher
                    ? const Radius.circular(16)
                    : const Radius.circular(4),
                bottomRight: message.isTeacher
                    ? const Radius.circular(4)
                    : const Radius.circular(16),
              ),
              border: Border.all(
                color: borderLight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.type == MessageType.text)
                  Text(
                    message.text,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: message.isTeacher
                          ? const Color(0xFF3B2A00)
                          : textDark,
                      height: 1.4,
                    ),
                  )
                else if (message.type == MessageType.audio)
                  _buildAudioMessage(message)
                else if (message.type == MessageType.file)
                  _buildFileMessage(message),
                const SizedBox(height: 4),
                Text(
                  message.time,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (message.isTeacher) ...[
            const SizedBox(width: 8),
          ],
        ],
      ),
    ).animate().fadeIn(delay: (200 + index * 100).ms, duration: 400.ms);
  }

  Widget _buildAudioMessage(ChatMessage message) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Play Button
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Waveform
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomPaint(
                  size: const Size(double.infinity, 24),
                  painter: WaveformPainter(color: const Color(0xFFD4AF37)),
                ),
                const SizedBox(height: 4),
                Text(
                  message.duration ?? '0:00',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileMessage(ChatMessage message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.insert_drive_file,
                color: Color(0xFFD4AF37), size: 18),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              message.text,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardLight,
        border: Border(
          top: BorderSide(color: borderLight),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE4E6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mic, color: Colors.redAccent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đang ghi âm ${_formatDuration(_recordingDuration)}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 18,
                  child: CustomPaint(
                    painter: WaveformPainter(color: const Color(0xFFD4AF37)),
                    size: const Size(double.infinity, 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: _cancelVoiceRecording,
            child: Text(
              'Hủy',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // QUICK ACTIONS ROW
  Widget _buildQuickActionsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cardLight,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Button 1: Send File
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _sendFile,
              icon: const Icon(Icons.attach_file, size: 16),
              label: Text(
                'Gửi file',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD4AF37),
                side: const BorderSide(color: Color(0xFFD4AF37)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Button 2: Send Homework (PRIMARY)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFB8941F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton.icon(
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
                icon: const Icon(Icons.assignment, size: 16),
                label: Text(
                  'Gửi bài tập',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Button 3: Schedule
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _scheduleLesson,
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(
                'Đặt lịch',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD4AF37),
                side: const BorderSide(color: Color(0xFFD4AF37)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  // INPUT FIELD
  Widget _buildInputField() {
    final hasText = _messageController.text.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attachment Button
          GestureDetector(
            onTap: _sendFile,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.attach_file,
                color: Color(0xFFD4AF37),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Text Input
          Expanded(
            child: TextField(
              controller: _messageController,
              style: GoogleFonts.inter(color: textDark),
              decoration: InputDecoration(
                hintText: 'Nhắn cho ${widget.studentName}...',
                hintStyle: GoogleFonts.inter(color: textMuted),
                filled: true,
                fillColor: cardAlt,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onChanged: (_) => setState(() {}),
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          // Voice/Send Button
          GestureDetector(
            onTap: hasText ? _sendMessage : _recordVoice,
            onLongPressStart: hasText ? null : (_) => _startVoiceRecording(),
            onLongPressEnd:
                hasText ? null : (_) => _stopVoiceRecording(send: true),
            onLongPressCancel: hasText ? null : _cancelVoiceRecording,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: hasText
                    ? const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFB8941F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: !hasText && _isRecording
                    ? const Color(0xFFFFE4E6)
                    : (!hasText ? const Color(0xFFD4AF37) : null),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                hasText ? Icons.send : Icons.mic,
                color: _isRecording ? Colors.redAccent : Colors.black,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  // HELPER METHODS
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final text = _messageController.text.trim();
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isTeacher: true,
        time: _nowLabel(),
        type: MessageType.text,
      ));
      _messageController.clear();
    });
    _scrollToBottom();
  }

  void _sendFile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
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
            const SizedBox(height: 16),
            Text(
              'Gửi file',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildMenuOption(
              Icons.photo_library_outlined,
              'Thư viện ảnh/video',
              () => _attachPickedItem('Video bài tập từ thư viện'),
            ),
            _buildMenuOption(
              Icons.description_outlined,
              'Tài liệu',
              () => _attachPickedItem('Tài liệu bài học (.pdf)'),
            ),
            _buildMenuOption(
              Icons.camera_alt_outlined,
              'Chụp ảnh nhanh',
              () => _attachPickedItem('Ảnh từ camera'),
            ),
            _buildMenuOption(
              Icons.audiotrack_outlined,
              'Tệp âm thanh',
              () => _attachPickedItem('Bản thu âm hướng dẫn'),
            ),
          ],
        ),
      ),
    );
  }

  void _attachPickedItem(String fileLabel) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: fileLabel,
          isTeacher: true,
          time: _nowLabel(),
          type: MessageType.file,
        ),
      );
    });
    _scrollToBottom();
  }

  void _scheduleLesson() {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 19, minute: 30);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(sheetContext).viewInsets.bottom + 16,
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
              const SizedBox(height: 16),
              Text(
                'Chốt lịch nhanh',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading:
                    const Icon(Icons.calendar_today, color: Color(0xFFD4AF37)),
                title: Text(
                  'Ngày học',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, color: textDark),
                ),
                subtitle: Text(
                  '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                  style: GoogleFonts.inter(color: textMuted),
                ),
                trailing: const Icon(Icons.chevron_right, color: textMuted),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setSheetState(() => selectedDate = picked);
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule, color: Color(0xFFD4AF37)),
                title: Text(
                  'Giờ học',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, color: textDark),
                ),
                subtitle: Text(
                  '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.inter(color: textMuted),
                ),
                trailing: const Icon(Icons.chevron_right, color: textMuted),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null) {
                    setSheetState(() => selectedTime = picked);
                  }
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final timeLabel =
                        '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')} • ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                    Navigator.pop(sheetContext);
                    setState(() {
                      _messages.add(
                        ChatMessage(
                          text: 'Đã chốt lịch buổi học: $timeLabel',
                          isTeacher: true,
                          time: _nowLabel(),
                          type: MessageType.text,
                        ),
                      );
                    });
                    _scrollToBottom();
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(
                    'Xác nhận lịch',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _recordVoice() {
    if (_isRecording) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Giữ nút mic để ghi âm, thả tay để gửi.',
          style: GoogleFonts.inter(color: textDark),
        ),
        backgroundColor: cardLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startVoiceRecording() {
    if (_isRecording) return;
    setState(() {
      _isRecording = true;
      _recordingDuration = Duration.zero;
    });
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isRecording) return;
      setState(() => _recordingDuration += const Duration(seconds: 1));
    });
  }

  void _stopVoiceRecording({bool send = false}) {
    if (!_isRecording) return;
    final duration = _recordingDuration;
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
      _recordingDuration = Duration.zero;
    });
    if (send && duration.inSeconds > 0) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: '',
            isTeacher: true,
            time: _nowLabel(),
            type: MessageType.audio,
            duration: _formatDuration(duration),
          ),
        );
      });
      _scrollToBottom();
    }
  }

  void _cancelVoiceRecording() {
    if (!_isRecording) return;
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
      _recordingDuration = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(1, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _nowLabel() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _editNextLesson() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardLight,
        title: Text(
          'Chỉnh sửa buổi học',
          style: GoogleFonts.inter(
            color: textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Tính năng sửa lịch đang được phát triển',
          style: GoogleFonts.inter(color: textDark),
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

  void _showOptionsMenu() {
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
            _buildMenuOption(Icons.person, 'Xem hồ sơ', () {}),
            _buildMenuOption(Icons.calendar_today, 'Xem lịch học', () {}),
            _buildMenuOption(Icons.volume_off, 'Tắt thông báo', () {}),
            _buildMenuOption(Icons.block, 'Chặn', () {}, isDestructive: true),
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

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

// Waveform Painter for Audio Messages
class WaveformPainter extends CustomPainter {
  final Color color;

  WaveformPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barCount = 30;
    final barWidth = size.width / barCount;

    for (int i = 0; i < barCount; i++) {
      final x = i * barWidth + barWidth / 2;
      final height =
          (i % 3 == 0 ? 0.7 : (i % 2 == 0 ? 0.5 : 0.3)) * size.height;
      final y1 = (size.height - height) / 2;
      final y2 = y1 + height;

      canvas.drawLine(Offset(x, y1), Offset(x, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Models
enum MessageType { text, audio, file }

class ChatMessage {
  final String text;
  final bool isTeacher;
  final String time;
  final MessageType type;
  final String? duration;

  ChatMessage({
    required this.text,
    required this.isTeacher,
    required this.time,
    required this.type,
    this.duration,
  });
}
