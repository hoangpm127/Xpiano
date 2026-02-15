import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'rental_deposit_screen.dart';

class PianoDetailScreen extends StatefulWidget {
  final String pianoId;
  final Map<String, dynamic> pianoData;

  const PianoDetailScreen({
    Key? key,
    required this.pianoId,
    required this.pianoData,
  }) : super(key: key);

  @override
  State<PianoDetailScreen> createState() => _PianoDetailScreenState();
}

class _PianoDetailScreenState extends State<PianoDetailScreen> {
  // Spiano Dark Luxury Colors
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color darkGold = Color(0xFFB39129);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);

  int _selectedImageIndex = 0;

  final List<String> _additionalImages = [
    'https://picsum.photos/400/300?random=10',
    'https://picsum.photos/400/300?random=11',
    'https://picsum.photos/400/300?random=12',
    'https://picsum.photos/400/300?random=13',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Content
          CustomScrollView(
            slivers: [
              // App Bar with Image
              _buildAppBar(),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildImageGallery(),
                    _buildFeatures(),
                    _buildDescription(),
                    _buildLocation(),
                    _buildReviews(),
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ],
          ),

          // Bottom Booking Button
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.pianoData['image'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: Center(
                    child: Icon(
                      Icons.piano,
                      size: 80,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.7),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isAvailable = widget.pianoData['available'] as bool;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category & Status
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryGold.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.pianoData['category'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryGold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Colors.green.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isAvailable ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isAvailable ? 'Sẵn sàng' : 'Đã thuê',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isAvailable ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn().slideX(begin: -0.2),

          const SizedBox(height: 16),

          // Name
          Text(
            widget.pianoData['name'],
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

          const SizedBox(height: 12),

          // Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: primaryGold,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                widget.pianoData['location'],
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 16),

          // Rating & Reviews
          Row(
            children: [
              Row(
                children: List.generate(5, (index) {
                  final rating = widget.pianoData['rating'] as double;
                  if (index < rating.floor()) {
                    return const Icon(Icons.star, color: primaryGold, size: 18);
                  } else if (index < rating) {
                    return const Icon(Icons.star_half,
                        color: primaryGold, size: 18);
                  } else {
                    return Icon(Icons.star_border,
                        color: Colors.grey[700], size: 18);
                  }
                }),
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.pianoData['rating']}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Text(
                ' (${widget.pianoData['reviews']} đánh giá)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 20),

          // Price
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryGold.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giá thuê',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.pianoData['price'],
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: primaryGold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: backgroundDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: primaryGold,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Theo giờ',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Hình ảnh',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _additionalImages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImageIndex = index;
                    });
                  },
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedImageIndex == index
                            ? primaryGold
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        _additionalImages[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[800],
                            child: Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildFeatures() {
    final features = widget.pianoData['features'] as List<String>;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiện ích',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: features.map((feature) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: primaryGold,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      feature,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mô tả',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Text(
              'Đàn piano chất lượng cao với âm thanh trong trẻ, phòng luyện tập rộng rãi, cách âm tốt. Phù hợp cho cả người mới bắt đầu và người chuyên nghiệp. Thiết bị được bảo dưỡng thường xuyên để đảm bảo chất lượng tốt nhất.',
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  Widget _buildLocation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vị trí',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Placeholder Map
                  Container(
                    color: Colors.grey[800],
                    child: Center(
                      child: Icon(
                        Icons.map,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  // Location Badge
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: primaryGold,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.pianoData['location'],
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.directions,
                            color: primaryGold,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildReviews() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đánh giá',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Xem tất cả',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryGold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Sample Review
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: primaryGold.withOpacity(0.2),
                      child: Text(
                        'A',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: primaryGold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Anh Tuấn',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                return Icon(
                                  Icons.star,
                                  color: primaryGold,
                                  size: 14,
                                );
                              }),
                              const SizedBox(width: 6),
                              Text(
                                '2 ngày trước',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Đàn rất tốt, âm thanh hay, phòng sạch sẽ. Chủ nhiệt tình. Giá cả hợp lý. Sẽ quay lại!',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 900.ms);
  }

  Widget _buildBottomButton() {
    final isAvailable = widget.pianoData['available'] as bool;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Contact Button
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryGold.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.phone,
                    color: primaryGold,
                  ),
                  onPressed: () {},
                ),
              ),

              const SizedBox(width: 12),

              // Booking Button
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isAvailable
                          ? [
                              const Color(0xFFE6C86E),
                              const Color(0xFFBF953F),
                              const Color(0xFFE6C86E),
                            ]
                          : [
                              Colors.grey[700]!,
                              Colors.grey[600]!,
                              Colors.grey[700]!
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isAvailable
                        ? [
                            BoxShadow(
                              color: primaryGold.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: isAvailable
                          ? () {
                              final initialPianoId =
                                  int.tryParse(widget.pianoId);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RentalDepositScreen(
                                    initialPianoId: initialPianoId,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Center(
                        child: Text(
                          isAvailable ? 'Đặt lịch ngay' : 'Không khả dụng',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
