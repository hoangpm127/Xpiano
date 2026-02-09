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
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index], index);
                },
              ),
            ),
            
            // QUICK ACTIONS
            _buildQuickActionsRow(),
            
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E2E),
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
                  color: const Color(0xFF2E2E2E),
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                color: const Color(0xFF2E2E2E),
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
                color: Colors.white,
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
        mainAxisAlignment: message.isTeacher 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
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
                  ? LinearGradient(
                      colors: [
                        const Color(0xFF4A3B10),
                        const Color(0xFF3A2F0E),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: message.isTeacher ? null : const Color(0xFF2C2C2C),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
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
                      color: Colors.white,
                      height: 1.4,
                    ),
                  )
                else if (message.type == MessageType.audio)
                  _buildAudioMessage(message),
                const SizedBox(height: 4),
                Text(
                  message.time,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
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
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
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
        color: const Color(0xFF1E1E1E),
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
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  // INPUT FIELD
  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
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
          // Attachment Button
          GestureDetector(
            onTap: _sendFile,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E2E),
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
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Nhắn cho ${widget.studentName}...',
                hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
                filled: true,
                fillColor: const Color(0xFF2E2E2E),
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
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          // Voice/Send Button
          GestureDetector(
            onTap: _messageController.text.isNotEmpty 
                ? _sendMessage 
                : _recordVoice,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFB8941F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _messageController.text.isNotEmpty 
                    ? Icons.send 
                    : Icons.mic,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.2, end: 0);
  }

  // HELPER METHODS
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(
        text: _messageController.text,
        isTeacher: true,
        time: '${DateTime.now().hour}:${DateTime.now().minute}',
        type: MessageType.text,
      ));
    });
    
    _messageController.clear();
    _scrollToBottom();
  }

  void _sendFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Chọn file để gửi',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _scheduleLesson() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tính năng đặt lịch đang được phát triển',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _recordVoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bắt đầu ghi âm',
          style: GoogleFonts.inter(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editNextLesson() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Chỉnh sửa buổi học',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Tính năng sửa lịch đang được phát triển',
          style: GoogleFonts.inter(color: Colors.white),
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
      backgroundColor: const Color(0xFF1E1E1E),
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

  Widget _buildMenuOption(IconData icon, String label, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFFD4AF37),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: isDestructive ? Colors.red : Colors.white,
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
      final height = (i % 3 == 0 ? 0.7 : (i % 2 == 0 ? 0.5 : 0.3)) * size.height;
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
