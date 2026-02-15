import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../services/supabase_service.dart';

class RentalHistoryScreen extends StatefulWidget {
  const RentalHistoryScreen({super.key});

  @override
  State<RentalHistoryScreen> createState() => _RentalHistoryScreenState();
}

class _RentalHistoryScreenState extends State<RentalHistoryScreen> {
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF666666);

  final SupabaseService _supabaseService = SupabaseService();
  final NumberFormat _money = NumberFormat('#,##0', 'vi_VN');
  bool _isLoading = true;
  List<Map<String, dynamic>> _rentals = const [];

  @override
  void initState() {
    super.initState();
    _loadRentals();
  }

  Future<void> _loadRentals() async {
    setState(() => _isLoading = true);
    final rentals = await _supabaseService.getMyRentals(limit: 100);
    if (!mounted) return;
    setState(() {
      _rentals = rentals;
      _isLoading = false;
    });
  }

  String _formatMoney(dynamic value) {
    final amount = (value as num?)?.toDouble() ?? 0;
    return '${_money.format(amount)}đ';
  }

  String _formatDate(dynamic value) {
    if (value == null) return '--';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return '--';
    return DateFormat('dd/MM/yyyy').format(parsed);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'returned':
        return Colors.blueGrey;
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.orange;
    }
  }

  Future<void> _cancelRental(String rentalId) async {
    try {
      await _supabaseService.cancelRental(rentalId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da huy yeu cau thue.')),
      );
      _loadRentals();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Huy that bai: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text(
          'Lich su thue',
          style: GoogleFonts.inter(
            color: textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        iconTheme: const IconThemeData(color: textDark),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRentals,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryGold))
            : _rentals.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Text(
                          'Ban chua co don thue nao.',
                          style: GoogleFonts.inter(color: textMuted),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _rentals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final rental = _rentals[index];
                      final piano = rental['pianos'] as Map<String, dynamic>?;
                      final status = (rental['status']?.toString() ?? 'pending')
                          .toLowerCase();
                      final rentalId = rental['id']?.toString() ?? '';
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    piano?['name']?.toString() ??
                                        'Piano #${rental['piano_id']}',
                                    style: GoogleFonts.inter(
                                      color: textDark,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _statusColor(status).withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    status,
                                    style: GoogleFonts.inter(
                                      color: _statusColor(status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_formatDate(rental['start_date'])} - ${_formatDate(rental['end_date'])}',
                              style: GoogleFonts.inter(
                                color: textMuted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tien thue: ${_formatMoney(rental['total_price'])}',
                              style: GoogleFonts.inter(
                                color: textMuted,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Tien coc: ${_formatMoney(rental['deposit_amount'])}',
                              style: GoogleFonts.inter(
                                color: textMuted,
                                fontSize: 13,
                              ),
                            ),
                            if (status == 'pending' && rentalId.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => _cancelRental(rentalId),
                                  child: Text(
                                    'Huy yeu cau',
                                    style: GoogleFonts.inter(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
