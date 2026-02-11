import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'chat_detail_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String _searchQuery = '';

  // Light Mode Palette
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color backgroundLight = Color(0xFFF7F7F7);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardAlt = Color(0xFFF1F1F1);
  static const Color borderLight = Color(0xFFE6E6E6);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B6B6B);
  
  // Mock data
  final List<Conversation> _conversations = [
    Conversation(
      studentName: 'Ánh',
      studentAvatar: 'https://i.pravatar.cc/150?img=1',
      level: 'Beginner',
      lastMessage: 'Cô ơi bài luyện ngón đoạn 2...',
      time: '09:12',
      hasUnread: true,
      nextLesson: 'Thứ 6 19:00',
    ),
    Conversation(
      studentName: 'Minh Tuấn',
      studentAvatar: 'https://i.pravatar.cc/150?img=12',
      level: 'Intermediate',
      lastMessage: 'Em đã hoàn thành bài tập rồi ạ',
      time: 'Hôm qua',
      hasUnread: false,
      nextLesson: 'Thứ 7 10:00',
    ),
    Conversation(
      studentName: 'Thu Hằng',
      studentAvatar: 'https://i.pravatar.cc/150?img=5',
      level: 'Advanced',
      lastMessage: 'Cảm ơn cô đã sửa bài!',
      time: '2 ngày',
      hasUnread: false,
      nextLesson: 'Thứ 5 20:30',
    ),
    Conversation(
      studentName: 'Bảo Trâm',
      studentAvatar: 'https://i.pravatar.cc/150?img=9',
      level: 'Intermediate',
      lastMessage: 'Sheet nhạc Canon in D ở đâu ạ?',
      time: '3 ngày',
      hasUnread: true,
      nextLesson: 'CN 15:00',
    ),
  ];

  List<Conversation> get _filteredConversations {
    if (_searchQuery.isEmpty) return _conversations;
    return _conversations
        .where((c) => c.studentName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            _buildHeader(),
            
            // CONVERSATION LIST
            Expanded(
              child: _filteredConversations.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filteredConversations.length,
                      itemBuilder: (context, index) {
                        final conversation = _filteredConversations[index];
                        return _buildConversationItem(conversation, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Title
              Expanded(
                child: Text(
                  'Tin nhắn',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ),
              // Search Icon
              GestureDetector(
                onTap: _showSearchDialog,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cardAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.search,
                    color: primaryGold,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Filter Icon
              GestureDetector(
                onTap: _showFilterDialog,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cardAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.filter_list,
                    color: primaryGold,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  // CONVERSATION ITEM
  Widget _buildConversationItem(Conversation conversation, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              studentName: conversation.studentName,
              studentAvatar: conversation.studentAvatar,
              level: conversation.level,
              nextLesson: conversation.nextLesson,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: conversation.hasUnread
                ? primaryGold.withOpacity(0.35)
                : borderLight,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
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
                  ),
                  child: ClipOval(
                    child: Image.network(
                      conversation.studentAvatar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: cardAlt,
                        child: const Icon(
                          Icons.person,
                          color: primaryGold,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                if (conversation.hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: primaryGold,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cardLight,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.studentName,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        conversation.time,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    conversation.lastMessage,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: conversation.hasUnread 
                          ? textDark 
                          : textMuted,
                      fontWeight: conversation.hasUnread 
                          ? FontWeight.w500 
                          : FontWeight.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 + index * 50).ms, duration: 400.ms);
  }

  // EMPTY STATE
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardAlt,
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryGold.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.message_outlined,
              color: primaryGold,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty 
                ? 'Chưa có tin nhắn nào' 
                : 'Không tìm thấy kết quả',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty 
                ? 'Tin nhắn từ học viên sẽ hiển thị ở đây' 
                : 'Thử tìm kiếm với từ khóa khác',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // DIALOGS
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardLight,
        title: Text(
          'Tìm kiếm',
          style: GoogleFonts.inter(
            color: textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          autofocus: true,
          style: GoogleFonts.inter(color: textDark),
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
          onChanged: (value) {
            setState(() => _searchQuery = value);
            Navigator.pop(context);
          },
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

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lọc tin nhắn',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 20),
            _buildFilterOption(Icons.circle, 'Chưa đọc', () {}),
            _buildFilterOption(Icons.people_outline, 'Tất cả học viên', () {}),
            _buildFilterOption(Icons.calendar_today, 'Có lịch tuần này', () {}),
            _buildFilterOption(Icons.assignment, 'Có bài tập chưa nộp', () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFD4AF37)),
      title: Text(
        label,
        style: GoogleFonts.inter(color: textDark, fontSize: 15),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}

// Model
class Conversation {
  final String studentName;
  final String studentAvatar;
  final String level;
  final String lastMessage;
  final String time;
  final bool hasUnread;
  final String nextLesson;

  Conversation({
    required this.studentName,
    required this.studentAvatar,
    required this.level,
    required this.lastMessage,
    required this.time,
    required this.hasUnread,
    required this.nextLesson,
  });
}

