import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class TeacherScheduleScreen extends StatefulWidget {
  const TeacherScheduleScreen({super.key});

  @override
  State<TeacherScheduleScreen> createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen> {
  // Light Mode Palette
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color backgroundLight = Color(0xFFF7F7F7);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardAlt = Color(0xFFF1F1F1);
  static const Color borderLight = Color(0xFFE6E6E6);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B6B6B);
  // Master toggles
  bool _onlineEnabled = true;
  bool _offlineEnabled = true;

  // Selected days for quick create
  Set<int> _selectedDays = {2}; // Monday = 1, Sunday = 7

  // Time pickers
  String _fromTime = '18:00';
  String _toTime = '22:00';

  // Current day highlight
  final int _currentDayOfWeek = DateTime.now().weekday; // 1-7

  // Mock schedule data
  final Map<int, List<ScheduleSlot>> _schedule = {
    1: [], // Monday
    2: [
      ScheduleSlot(time: '10:00', type: ScheduleSlotType.online),
      ScheduleSlot(time: '14:00', type: ScheduleSlotType.offline),
    ],
    3: [
      ScheduleSlot(time: '09:00', type: ScheduleSlotType.online),
    ],
    4: [
      ScheduleSlot(time: '15:00', type: ScheduleSlotType.blocked),
    ],
    5: [
      ScheduleSlot(time: '10:00', type: ScheduleSlotType.online),
      ScheduleSlot(time: '13:30', type: ScheduleSlotType.offline),
      ScheduleSlot(time: '23:00', type: ScheduleSlotType.blocked),
    ],
    6: [],
    7: [],
  };

  final List<String> _dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  final List<String> _hours = [
    '07:00', '08:00', '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00', '17:00', '18:00',
    '19:00', '20:00', '21:00', '22:00', '23:00',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildMasterToggles(),
            Expanded(
              child: _buildWeeklyGrid(),
            ),
          ],
        ),
      ),
      bottomSheet: _buildQuickCreatePanel(),
    );
  }

  // 1. HEADER
  Widget _buildHeader() {
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
          IconButton(
            icon: const Icon(Icons.arrow_back, color: textDark),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Lịch dạy',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
              textAlign: TextAlign.center,
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
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Color(0xFFD4AF37)),
                const SizedBox(width: 6),
                Text(
                  'Hôm nay',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  // 2. MASTER TOGGLES
  Widget _buildMasterToggles() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          Text(
            'Chế độ nhận booking',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildToggleRow(
            icon: Icons.computer,
            label: 'Mở lịch Online',
            value: _onlineEnabled,
            onChanged: (val) => setState(() => _onlineEnabled = val),
          ),
          const SizedBox(height: 12),
          _buildToggleRow(
            icon: Icons.people,
            label: 'Mở lịch Offline',
            value: _offlineEnabled,
            onChanged: (val) => setState(() => _offlineEnabled = val),
          ),
          const SizedBox(height: 12),
          Text(
            'Bật/tắt để nhận booking theo hình thức',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: textMuted,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFD4AF37),
          activeTrackColor: const Color(0xFFD4AF37).withOpacity(0.5),
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey.withOpacity(0.3),
        ),
      ],
    );
  }

  // 3. WEEKLY GRID
  Widget _buildWeeklyGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          _buildDayHeader(),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: _buildTimeGrid(),
            ),
          ),
          const SizedBox(height: 12),
          _buildLegend(),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildDayHeader() {
    return Row(
      children: [
        const SizedBox(width: 50), // Space for time labels
        for (int i = 0; i < 7; i++)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: i + 1 == _currentDayOfWeek
                    ? const Color(0xFFD4AF37).withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: i + 1 == _currentDayOfWeek
                    ? Border.all(color: const Color(0xFFD4AF37), width: 2)
                    : null,
              ),
              child: Text(
                _dayLabels[i],
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: i + 1 == _currentDayOfWeek ? FontWeight.bold : FontWeight.w500,
                  color: i + 1 == _currentDayOfWeek ? const Color(0xFFD4AF37) : textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeGrid() {
    return Column(
      children: _hours.map((hour) => _buildTimeRow(hour)).toList(),
    );
  }

  Widget _buildTimeRow(String hour) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: borderLight,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              hour,
              style: GoogleFonts.robotoMono(
                fontSize: 11,
                color: textMuted,
              ),
            ),
          ),
          for (int day = 1; day <= 7; day++)
            Expanded(
              child: _buildTimeCell(day, hour),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeCell(int day, String hour) {
    final slot = _schedule[day]?.firstWhere(
      (s) => s.time == hour,
      orElse: () => ScheduleSlot(time: '', type: ScheduleSlotType.none),
    );

    if (slot == null || slot.type == ScheduleSlotType.none) {
      return GestureDetector(
        onTap: () => _showSlotDialog(day, hour),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(
              color: borderLight,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }

    Color bgColor;
    String label;
    
    switch (slot.type) {
      case ScheduleSlotType.online:
        bgColor = const Color(0xFFD4AF37);
        label = 'Online';
        break;
      case ScheduleSlotType.offline:
        bgColor = const Color(0xFFF5E1A4);
        label = 'Offline';
        break;
      case ScheduleSlotType.blocked:
        bgColor = textMuted;
        label = 'Đã chặn';
        break;
      default:
        bgColor = Colors.transparent;
        label = '';
    }

    return GestureDetector(
      onTap: () => _showSlotDialog(day, hour, existingSlot: slot),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: bgColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: slot.type == ScheduleSlotType.offline ? Colors.black87 : Colors.black,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(const Color(0xFFD4AF37), 'Online'),
        const SizedBox(width: 16),
        _buildLegendItem(const Color(0xFFF5E1A4), 'Offline'),
        const SizedBox(width: 16),
        _buildLegendItem(textMuted, 'Đã chặn'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: textMuted,
          ),
        ),
      ],
    );
  }

  // 4. QUICK CREATE PANEL
  Widget _buildQuickCreatePanel() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tạo khung giờ rảnh',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Chọn ngày',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 8),
          _buildDaySelector(),
          const SizedBox(height: 16),
          Text(
            'Chọn giờ',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTimeDropdown('Từ', _fromTime, (val) => setState(() => _fromTime = val))),
              const SizedBox(width: 12),
              Expanded(child: _buildTimeDropdown('Đến', _toTime, (val) => setState(() => _toTime = val))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Đã thêm khung giờ!',
                          style: GoogleFonts.inter(color: textDark),
                        ),
                        backgroundColor: const Color(0xFFD4AF37),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    'Thêm khung giờ',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD4AF37),
                    side: const BorderSide(color: Color(0xFFD4AF37)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Đã chặn lịch!',
                          style: GoogleFonts.inter(color: textDark),
                        ),
                        backgroundColor: Colors.grey,
                      ),
                    );
                  },
                  icon: const Icon(Icons.block, size: 18),
                  label: Text(
                    'Chặn lịch',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '✓ Đã lưu lịch thành công!',
                      style: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                'Lưu lịch',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lịch được đồng bộ ngay sau khi lưu',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Wrap(
      spacing: 8,
      children: List.generate(7, (index) {
        final day = index + 1;
        final isSelected = _selectedDays.contains(day);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(day);
              } else {
                _selectedDays.add(day);
              }
            });
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFFD4AF37) : textMuted,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _dayLabels[index],
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.black : textMuted,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimeDropdown(String label, String value, ValueChanged<String> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cardAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label $value',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Icon(Icons.access_time, size: 18, color: Color(0xFFD4AF37)),
        ],
      ),
    );
  }

  void _showSlotDialog(int day, String hour, {ScheduleSlot? existingSlot}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardLight,
        title: Text(
          existingSlot != null ? 'Chỉnh sửa slot' : 'Tạo slot mới',
          style: GoogleFonts.inter(color: textDark, fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${_dayLabels[day - 1]} - $hour',
          style: GoogleFonts.inter(color: textMuted),
        ),
        actions: [
          if (existingSlot != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _schedule[day]?.removeWhere((s) => s.time == hour);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa slot', style: GoogleFonts.inter(color: textDark)),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Text('Xóa', style: GoogleFonts.inter(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng', style: GoogleFonts.inter(color: textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tạo slot thành công!', style: GoogleFonts.inter(color: textDark)),
                  backgroundColor: const Color(0xFFD4AF37),
                ),
              );
            },
            child: Text('Lưu', style: GoogleFonts.inter(color: const Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }
}

// Model
class ScheduleSlot {
  final String time;
  final ScheduleSlotType type;

  ScheduleSlot({required this.time, required this.type});
}

enum ScheduleSlotType {
  none,
  online,
  offline,
  blocked,
}


