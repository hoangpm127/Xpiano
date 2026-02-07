import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../services/supabase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Constants
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color backgroundDark = Color(0xFF121212);
  final SupabaseService _supabaseService = SupabaseService();

  // State
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
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
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('Xác nhận hủy', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn hủy lịch đặt này không?', style: GoogleFonts.inter(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Không', style: GoogleFonts.inter(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hủy Lịch', style: GoogleFonts.inter(color: Colors.redAccent)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Profile Header
            _buildProfileHeader(),
            
            const SizedBox(height: 20),
            
            // 2. Section Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.history, color: primaryGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Lịch sử đặt đàn',
                    style: GoogleFonts.inter(
                      color: Colors.white,
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
                  ? const Center(child: CircularProgressIndicator(color: primaryGold))
                  : _bookings.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _fetchBookings,
                          color: primaryGold,
                          backgroundColor: Colors.black,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _bookings.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return _buildBookingCard(_bookings[index]);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder avatar
            backgroundColor: Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            'Linh Piano',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Thành viên Vàng',
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
              _buildStatItem('${_bookings.length}', 'Bookings'),
              _buildStatItem('12h', 'Practice'),
              _buildStatItem('Gold', 'Rank'),
            ],
          ),
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
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 60, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'Chưa có lịch đặt nào',
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 16),
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
        statusColor = Colors.white;
        statusText = booking.status;
    }

    final isCancelable = (booking.status == 'confirmed' || booking.status == 'pending') &&
        booking.startTime.isAfter(DateTime.now());

    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('HH:mm');
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                width: 60, height: 60,
                color: Colors.grey[800],
                child: const Icon(Icons.music_note, color: Colors.white54),
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
                    color: Colors.white,
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
                    color: Colors.white70,
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
}
