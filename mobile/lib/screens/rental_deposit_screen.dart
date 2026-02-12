import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/piano.dart';
import '../services/supabase_service.dart';

class RentalDepositScreen extends StatefulWidget {
  final int? initialPianoId;

  const RentalDepositScreen({
    super.key,
    this.initialPianoId,
  });

  @override
  State<RentalDepositScreen> createState() => _RentalDepositScreenState();
}

class _RentalDepositScreenState extends State<RentalDepositScreen> {
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color surfaceLight = Color(0xFFF7F7F7);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF666666);

  final SupabaseService _supabaseService = SupabaseService();
  final NumberFormat _money = NumberFormat('#,##0', 'vi_VN');

  bool _isLoadingPianos = true;
  bool _isSubmitting = false;
  List<Piano> _pianos = const [];
  Piano? _selectedPiano;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadPianos();
  }

  Future<void> _loadPianos() async {
    setState(() => _isLoadingPianos = true);
    final pianos = await _supabaseService.getPianos();
    if (!mounted) return;

    Piano? selected;
    if (widget.initialPianoId != null) {
      for (final item in pianos) {
        if (item.id == widget.initialPianoId) {
          selected = item;
          break;
        }
      }
    }
    selected ??= pianos.isNotEmpty ? pianos.first : null;

    final today = DateTime.now();
    setState(() {
      _pianos = pianos;
      _selectedPiano = selected;
      _startDate ??= DateTime(today.year, today.month, today.day);
      _endDate ??= _startDate;
      _isLoadingPianos = false;
    });
  }

  int get _rentalDays {
    if (_startDate == null || _endDate == null) return 0;
    final start =
        DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
    final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
    return end.difference(start).inDays + 1;
  }

  double get _dailyPrice => _selectedPiano?.dailyPrice ?? 0;
  double get _depositAmount => _selectedPiano?.depositAmount ?? 0;
  double get _totalPrice => _dailyPrice * _rentalDays;
  double get _payNow => _totalPrice + _depositAmount;

  bool get _isPianoAvailable {
    final piano = _selectedPiano;
    if (piano == null) return false;
    final status = piano.status.toLowerCase();
    if (status == 'maintenance' || status == 'rented') return false;
    return piano.isAvailable ?? true;
  }

  Future<void> _pickStartDate() async {
    final today = DateTime.now();
    final firstDate = DateTime(today.year, today.month, today.day);
    final initial = _startDate ?? firstDate;
    final picked = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 365)),
      initialDate: initial,
    );
    if (picked == null || !mounted) return;

    setState(() {
      _startDate = DateTime(picked.year, picked.month, picked.day);
      if (_endDate == null || _endDate!.isBefore(_startDate!)) {
        _endDate = _startDate;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final today = DateTime.now();
    final start = _startDate ?? DateTime(today.year, today.month, today.day);
    final picked = await showDatePicker(
      context: context,
      firstDate: start,
      lastDate: start.add(const Duration(days: 365)),
      initialDate:
          _endDate?.isBefore(start) == true ? start : (_endDate ?? start),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _endDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  String _formatCurrency(double value) => '${_money.format(value)}đ';

  String _formatDate(DateTime? value) {
    if (value == null) return '--';
    return DateFormat('dd/MM/yyyy').format(value);
  }

  String _mapRentalError(Object error) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('rental_conflict') ||
        raw.contains('already rented') ||
        raw.contains('conflict')) {
      return 'Khung ngày này đã có người thuê. Vui lòng chọn ngày khác.';
    }
    if (raw.contains('auth_required') || raw.contains('not authenticated')) {
      return 'Vui lòng đăng nhập để đặt thuê.';
    }
    if (raw.contains('invalid_date_range')) {
      return 'Khoảng thời gian thuê không hợp lệ.';
    }
    return 'Đặt thuê thất bại. Vui lòng thử lại.';
  }

  Future<void> _submitRental() async {
    if (_selectedPiano == null || _startDate == null || _endDate == null) {
      return;
    }
    if (!_isPianoAvailable) return;

    final user = _supabaseService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn cần đăng nhập để đặt thuê.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _supabaseService.createRentalAtomic(
        pianoId: _selectedPiano!.id,
        startDate: _startDate!,
        endDate: _endDate!,
        totalPrice: _totalPrice,
        depositAmount: _depositAmount,
        status: 'pending',
      );

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: cardLight,
          title: Text(
            'Đặt thuê thành công',
            style: GoogleFonts.inter(
              color: textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Yêu cầu thuê đã được tạo. Bạn có thể xem lại trong lịch sử thuê.',
            style: GoogleFonts.inter(color: textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Đóng',
                style: GoogleFonts.inter(color: primaryGold),
              ),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_mapRentalError(e))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceLight,
      appBar: AppBar(
        title: Text(
          'Dat thue piano',
          style: GoogleFonts.inter(
            color: textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: surfaceLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDark),
      ),
      body: _isLoadingPianos
          ? const Center(child: CircularProgressIndicator(color: primaryGold))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_pianos.isEmpty) {
      return Center(
        child: Text(
          'Chưa có đàn để thuê.',
          style: GoogleFonts.inter(color: textMuted),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn đàn',
            style: GoogleFonts.inter(
              color: textDark,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _selectedPiano?.id,
            decoration: InputDecoration(
              filled: true,
              fillColor: cardLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            items: _pianos
                .map(
                  (piano) => DropdownMenuItem<int>(
                    value: piano.id,
                    child: Text(
                      piano.name,
                      style: GoogleFonts.inter(color: textDark),
                    ),
                  ),
                )
                .toList(),
            onChanged: (id) {
              if (id == null) return;
              for (final item in _pianos) {
                if (item.id == id) {
                  setState(() => _selectedPiano = item);
                  break;
                }
              }
            },
          ),
          const SizedBox(height: 16),
          _buildPianoPreview(),
          const SizedBox(height: 16),
          _buildDatePickerCard(),
          const SizedBox(height: 16),
          _buildPriceSummary(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
                  (_isSubmitting || !_isPianoAvailable || _rentalDays <= 0)
                      ? null
                      : _submitRental,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      _isPianoAvailable ? 'Dat thue' : 'Dan khong kha dung',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPianoPreview() {
    final piano = _selectedPiano;
    if (piano == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              piano.imageUrl,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: Colors.grey.shade200,
                child: const Icon(Icons.piano),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  piano.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gia/ngay: ${_formatCurrency(piano.dailyPrice)}',
                  style: GoogleFonts.inter(color: textMuted, fontSize: 13),
                ),
                Text(
                  'Tien coc: ${_formatCurrency(piano.depositAmount)}',
                  style: GoogleFonts.inter(color: textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerCard() {
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
          Text(
            'Thoi gian thue',
            style: GoogleFonts.inter(
              color: textDark,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickStartDate,
                  icon: const Icon(Icons.event_available),
                  label: Text(_formatDate(_startDate)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickEndDate,
                  icon: const Icon(Icons.event),
                  label: Text(_formatDate(_endDate)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'So ngay thue: $_rentalDays',
            style: GoogleFonts.inter(color: textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Don gia/ngay', _formatCurrency(_dailyPrice)),
          _buildSummaryRow('Tien thue', _formatCurrency(_totalPrice)),
          _buildSummaryRow('Tien coc', _formatCurrency(_depositAmount)),
          const Divider(height: 24),
          _buildSummaryRow('Tong tam tinh', _formatCurrency(_payNow),
              isStrong: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isStrong = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: textMuted,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: isStrong ? textDark : textMuted,
              fontSize: isStrong ? 16 : 14,
              fontWeight: isStrong ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
