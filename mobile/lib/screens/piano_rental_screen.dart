import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'piano_detail_screen.dart';
import '../services/supabase_service.dart';
import '../models/piano.dart';

class PianoRentalScreen extends StatefulWidget {
  const PianoRentalScreen({Key? key}) : super(key: key);

  @override
  State<PianoRentalScreen> createState() => _PianoRentalScreenState();
}

class _PianoRentalScreenState extends State<PianoRentalScreen> {
  // Spiano Dark Luxury Colors
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB39129);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);

  final SupabaseService _supabaseService = SupabaseService();
  late Future<List<Piano>> _pianosFuture;

  String _selectedCategory = 'Tất cả';
  final List<String> _categories = [
    'Tất cả',
    'Grand Piano',
    'Upright Piano',
    'Digital Piano',
    'Keyboard',
  ];

  @override
  void initState() {
    super.initState();
    _pianosFuture = _supabaseService.getPianos();
  }

  void _refreshPianos() {
    setState(() {
      _pianosFuture = _supabaseService.getPianos(
        category: _selectedCategory == 'Tất cả' ? null : _selectedCategory,
      );
    });
  }

  // Mock data removed - now fetched from Supabase
  final List<Map<String, dynamic>> _pianos_old = [
    {
      'id': 'piano_001',
      'name': 'Yamaha C3X Grand Piano',
      'category': 'Grand Piano',
      'price': '500,000đ/giờ',
      'location': 'Quận 1, TP.HCM',
      'rating': 4.9,
      'reviews': 128,
      'image': 'https://picsum.photos/400/300?random=1',
      'available': true,
      'features': ['Âm thanh đỉnh cao', 'Phòng cách âm', 'Điều hòa'],
    },
    {
      'id': 'piano_002',
      'name': 'Kawai K-300 Upright',
      'category': 'Upright Piano',
      'price': '300,000đ/giờ',
      'location': 'Quận 3, TP.HCM',
      'rating': 4.8,
      'reviews': 86,
      'image': 'https://picsum.photos/400/300?random=2',
      'available': true,
      'features': ['Phòng rộng rãi', 'Miễn phí nước', 'Free WiFi'],
    },
    {
      'id': 'piano_003',
      'name': 'Yamaha P-125 Digital',
      'category': 'Digital Piano',
      'price': '150,000đ/giờ',
      'location': 'Quận 7, TP.HCM',
      'rating': 4.7,
      'reviews': 64,
      'image': 'https://picsum.photos/400/300?random=3',
      'available': true,
      'features': ['Tai nghe chống ồn', 'Ghi âm', 'USB MIDI'],
    },
    {
      'id': 'piano_004',
      'name': 'Steinway Model D Grand',
      'category': 'Grand Piano',
      'price': '1,200,000đ/giờ',
      'location': 'Quận 1, TP.HCM',
      'rating': 5.0,
      'reviews': 245,
      'image': 'https://picsum.photos/400/300?random=4',
      'available': true,
      'features': ['Concert Hall', 'Âm thanh hoàn hảo', 'Bảo dưỡng định kỳ'],
    },
    {
      'id': 'piano_005',
      'name': 'Roland FP-30X Digital',
      'category': 'Digital Piano',
      'price': '120,000đ/giờ',
      'location': 'Quận 2, TP.HCM',
      'rating': 4.6,
      'reviews': 52,
      'image': 'https://picsum.photos/400/300?random=5',
      'available': false,
      'features': ['Bluetooth Audio', 'Portable', '88 phím'],
    },
    {
      'id': 'piano_006',
      'name': 'Casio Privia PX-S1100',
      'category': 'Keyboard',
      'price': '100,000đ/giờ',
      'location': 'Quận 10, TP.HCM',
      'rating': 4.5,
      'reviews': 38,
      'image': 'https://picsum.photos/400/300?random=6',
      'available': true,
      'features': ['Siêu mỏng', 'Pin sạc', 'Loa tích hợp'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Categories
            _buildCategories(),
            
            // Piano List
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
                        'Lỗi: ${snapshot.error}',
                        style: GoogleFonts.inter(color: Colors.black),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'Chưa có đàn nào',
                        style: GoogleFonts.inter(color: Colors.black),
                      ),
                    );
                  }
                  
                  // Filter by category
                  final pianos = _selectedCategory == 'Tất cả'
                      ? snapshot.data!
                      : snapshot.data!.where((p) => p.category == _selectedCategory).toList();
                  
                  return _buildPianoList(pianos);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thuê đàn',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
          const SizedBox(height: 8),
          Text(
            'Tìm đàn piano phù hợp với bạn',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 20),
          
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Colors.grey[600],
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tìm kiếm đàn, địa điểm...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
                Icon(
                  Icons.tune,
                  color: primaryGold,
                  size: 22,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                  _refreshPianos();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? primaryGold.withOpacity(0.15) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? primaryGold : Colors.grey[300]!,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? primaryGold : Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: (100 + index * 50).ms).slideX(
              begin: 0.2,
              duration: 400.ms,
              delay: (100 + index * 50).ms,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPianoList(List<Piano> pianos) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: pianos.length,
      itemBuilder: (context, index) {
        final piano = pianos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildPianoCard(piano, index),
        );
      },
    );
  }

  Widget _buildPianoCard(Piano piano, int index) {
    final isAvailable = piano.isAvailable ?? true;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PianoDetailScreen(
              pianoId: piano.id.toString(),
              pianoData: piano.toPianoData(),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    piano.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[800],
                        child: Center(
                          child: Icon(
                            Icons.piano,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Status Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isAvailable 
                          ? Colors.green.withOpacity(0.9)
                          : Colors.grey.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isAvailable ? 'Sẵn sàng' : 'Đã thuê',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                // Category Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      piano.category,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: primaryGold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    piano.name,
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: primaryGold,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        piano.location,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Features
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: piano.features.take(3).map((feature) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          feature,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey[700],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Price & Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            piano.formattedPrice,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: primaryGold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: primaryGold,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${piano.rating}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              ' (${piano.reviewsCount})',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 100).ms).slideY(
        begin: 0.2,
        duration: 400.ms,
        delay: (index * 100).ms,
      ),
    );
  }
}
