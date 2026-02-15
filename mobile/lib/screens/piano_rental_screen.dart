import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/piano.dart';
import '../services/supabase_service.dart';
import 'piano_detail_screen.dart';
import 'rental_deposit_screen.dart';
import 'rental_history_screen.dart';

class PianoRentalScreen extends StatefulWidget {
  const PianoRentalScreen({super.key});

  @override
  State<PianoRentalScreen> createState() => _PianoRentalScreenState();
}

class _PianoRentalScreenState extends State<PianoRentalScreen> {
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF666666);

  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Piano>> _pianosFuture;

  String _selectedCategory = 'Tất cả';
  final List<String> _categories = const [
    'Tất cả',
    'Grand Piano',
    'Upright Piano',
    'Digital Piano',
    'Keyboard',
  ];

  @override
  void initState() {
    super.initState();
    _reloadPianos();
  }

  void _reloadPianos() {
    setState(() {
      _pianosFuture = _supabaseService.getPianos(
        category: _selectedCategory == 'Tất cả' ? null : _selectedCategory,
      );
    });
  }

  bool _isAvailable(Piano piano) {
    final status = piano.status.toLowerCase();
    if (status == 'rented' || status == 'maintenance') return false;
    return piano.isAvailable ?? true;
  }

  String _statusLabel(Piano piano) {
    final status = piano.status.toLowerCase();
    if (status == 'maintenance') return 'Bao tri';
    if (status == 'rented') return 'Da thue';
    return 'San sang';
  }

  void _openRentalFlow(Piano piano) {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RentalDepositScreen(initialPianoId: piano.id),
      ),
    ).then((updated) {
      if (updated == true) {
        _reloadPianos();
      }
    });
  }

  void _openRentalHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RentalHistoryScreen()),
    );
  }

  void _openDetail(Piano piano) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PianoDetailScreen(
          pianoId: piano.id.toString(),
          pianoData: piano.toPianoData(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategories(),
            Expanded(
              child: FutureBuilder<List<Piano>>(
                future: _pianosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: primaryGold),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Loi tai du lieu: ${snapshot.error}',
                        style: GoogleFonts.inter(color: textDark),
                      ),
                    );
                  }
                  final pianos = snapshot.data ?? const [];
                  if (pianos.isEmpty) {
                    return Center(
                      child: Text(
                        'Chua co dan phu hop',
                        style: GoogleFonts.inter(color: textMuted),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pianos.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPianoCard(pianos[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thue dan',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Chon piano, chon ngay, dat coc',
                  style: GoogleFonts.inter(
                    color: textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Lich su thue',
            onPressed: _openRentalHistory,
            icon: const Icon(Icons.receipt_long, color: textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(
                category,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.black : textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              selectedColor: primaryGold,
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300),
              onSelected: (_) {
                _selectedCategory = category;
                _reloadPianos();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPianoCard(Piano piano) {
    final available = _isAvailable(piano);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  piano.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.piano)),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: available ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusLabel(piano),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  piano.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: textDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  piano.category,
                  style: GoogleFonts.inter(color: textMuted, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_month,
                        size: 16, color: primaryGold),
                    const SizedBox(width: 6),
                    Text(
                      piano.formattedDailyPrice,
                      style: GoogleFonts.inter(
                        color: textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Coc: ${piano.formattedDeposit}',
                      style: GoogleFonts.inter(
                        color: textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _openDetail(piano),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textDark,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Chi tiet'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            available ? () => _openRentalFlow(piano) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGold,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Dat thue'),
                      ),
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
