import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/piano.dart';
import '../services/supabase_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // Constants
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color backgroundDark = Color(0xFF121212);
  final SupabaseService _supabaseService = SupabaseService();

  // State
  String _selectedCategory = 'All';
  List<Piano> _pianos = [];
  bool _isLoading = true;
  bool _isGuest = false;

  // Categories
  final List<String> _categories = ['All', 'Grand Piano', 'Upright Piano', 'Digital Piano'];

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _fetchPianos();
  }
  
  void _checkAuth() {
    final user = _supabaseService.currentUser;
    setState(() {
      _isGuest = user == null;
    });
  }

  Future<void> _fetchPianos() async {
    setState(() => _isLoading = true);
    final pianos = await _supabaseService.getPianos(category: _selectedCategory);
    setState(() {
      _pianos = pianos;
      _isLoading = false;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _fetchPianos();
  }

  void _showBookingSheet(BuildContext context, Piano piano) {
    // Double check auth before opening sheet
    final user = _supabaseService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để đặt đàn!'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context); // Go back to feed
      return;
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingSheet(piano: piano, supabaseService: _supabaseService),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        title: Text(
          'Mượn Đàn',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 1. Categories
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(
                      category,
                      style: GoogleFonts.inter(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) => _onCategorySelected(category),
                    selectedColor: primaryGold,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    side: BorderSide.none,
                  ),
                );
              },
            ),
          ),

          // 2. Pianos List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryGold))
                : _pianos.isEmpty
                    ? Center(child: Text("Không tìm thấy đàn nào", style: GoogleFonts.inter(color: Colors.white)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _pianos.length,
                        itemBuilder: (context, index) {
                          return _buildPianoCard(_pianos[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPianoCard(Piano piano) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              piano.imageUrl.isNotEmpty ? piano.imageUrl : 'https://via.placeholder.com/400x200',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 180, color: Colors.grey[800], child: const Icon(Icons.music_note, color: Colors.white)),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        piano.name,
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: primaryGold, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          piano.formattedRating,
                          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  piano.category,
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      piano.formattedPrice,
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: primaryGold),
                    ),
                    ElevatedButton(
                      onPressed: () => _showBookingSheet(context, piano),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Chọn'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookingSheet extends StatefulWidget {
  final Piano piano;
  final SupabaseService supabaseService;

  const BookingSheet({super.key, required this.piano, required this.supabaseService});

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTimeSlot;
  bool _isProcessing = false;

  final List<String> _timeSlots = List.generate(14, (index) {
    final hour = index + 8; // Start from 8:00
    return '${hour.toString().padLeft(2, '0')}:00';
  }); // 08:00 to 21:00

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  void _onBookingConfirmed() async {
    if (_selectedDay == null || _selectedTimeSlot == null) return;

    setState(() => _isProcessing = true);

    try {
      // Parse time slot
      final timeParts = _selectedTimeSlot!.split(':');
      final hour = int.parse(timeParts[0]);
      
      final startTime = DateTime(
        _selectedDay!.year, 
        _selectedDay!.month, 
        _selectedDay!.day, 
        hour
      );
      final endTime = startTime.add(const Duration(hours: 1)); // Default 1 hour booking

      await widget.supabaseService.createBooking(
        pianoId: widget.piano.id,
        startTime: startTime,
        endTime: endTime,
        totalPrice: widget.piano.pricePerHour, // Assuming 1 hour for MVP
      );

      if (mounted) {
        Navigator.pop(context); // Close sheet
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 60),
            const SizedBox(height: 16),
            Text(
              'Đặt lịch thành công!',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Cảm ơn bạn đã sử dụng dịch vụ.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to Home (Assuming BookingScreen was pushed)
            },
            child: Text('Về trang chủ', style: GoogleFonts.inter(color: const Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.piano.imageUrl.isNotEmpty ? widget.piano.imageUrl : 'https://via.placeholder.com/100',
                    width: 60, height: 60, fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.piano.name, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(widget.piano.formattedPrice, style: GoogleFonts.inter(color: const Color(0xFFD4AF37), fontSize: 14)),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(color: Colors.white10),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar
                  TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 30)),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                        _selectedTimeSlot = null; // Reset time slot on date change
                      });
                    },
                    calendarStyle: const CalendarStyle(
                      defaultTextStyle: TextStyle(color: Colors.white),
                      weekendTextStyle: TextStyle(color: Colors.white70),
                      outsideTextStyle: TextStyle(color: Colors.white24),
                      selectedDecoration: BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle),
                      todayDecoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                      rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Text('Chọn khung giờ', style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  // Time Slots Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _timeSlots.length,
                    itemBuilder: (context, index) {
                      final time = _timeSlots[index];
                      final isSelected = time == _selectedTimeSlot;
                      return InkWell(
                        onTap: () => setState(() => _selectedTimeSlot = time),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSelected ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.1)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            time,
                            style: GoogleFonts.inter(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 100), // Spacing for bottom fixed area
                ],
              ),
            ),
          ),
          
          // Bottom Summary Fixed
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  if (_selectedDay != null && _selectedTimeSlot != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${DateFormat('dd/MM/yyyy').format(_selectedDay!)} - $_selectedTimeSlot',
                            style: GoogleFonts.inter(color: Colors.white70),
                          ),
                          Text(
                            widget.piano.formattedPrice,
                            style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_selectedDay != null && _selectedTimeSlot != null && !_isProcessing)
                          ? _onBookingConfirmed
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        disabledBackgroundColor: Colors.white12,
                        disabledForegroundColor: Colors.white38,
                      ),
                      child: _isProcessing
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : Text('Xác nhận đặt', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
