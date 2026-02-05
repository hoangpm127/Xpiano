import 'package:flutter/material.dart';
import '../models/piano_model.dart';
import 'piano_detail_screen.dart';

class RentalScreen extends StatelessWidget {
  const RentalScreen({super.key});

  // Danh sách đàn Piano giả (Dummy Data)
  List<PianoModel> get pianoList => [
        PianoModel(
          id: '1',
          name: 'Yamaha P-45',
          imageUrl: 'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=800',
          pricePerMonth: 500000,
          isAvailable: true,
          brand: 'Yamaha',
          description: 'Đàn piano điện tử 88 phím cảm ứng lực, âm thanh chất lượng cao, phù hợp cho người mới bắt đầu.',
          keys: 88,
        ),
        PianoModel(
          id: '2',
          name: 'Casio CDP-S110',
          imageUrl: 'https://images.unsplash.com/photo-1511192336575-5a79af67a629?w=800',
          pricePerMonth: 450000,
          isAvailable: true,
          brand: 'Casio',
          description: 'Thiết kế mỏng nhẹ, dễ di chuyển. 88 phím cảm ứng lực, âm thanh tự nhiên.',
          keys: 88,
        ),
        PianoModel(
          id: '3',
          name: 'Roland FP-10',
          imageUrl: 'https://images.unsplash.com/photo-1552422535-c45813c61732?w=800',
          pricePerMonth: 650000,
          isAvailable: true,
          brand: 'Roland',
          description: 'Piano cao cấp với công nghệ âm thanh SuperNATURAL, cảm giác phím gần với đàn Grand Piano.',
          keys: 88,
        ),
        PianoModel(
          id: '4',
          name: 'Korg B2',
          imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
          pricePerMonth: 550000,
          isAvailable: false,
          brand: 'Korg',
          description: '88 phím cảm ứng lực, 12 âm sắc khác nhau, hệ thống loa 2x15W mạnh mẽ.',
          keys: 88,
        ),
        PianoModel(
          id: '5',
          name: 'Kawai ES110',
          imageUrl: 'https://images.unsplash.com/photo-1571974599782-87624638275e?w=800',
          pricePerMonth: 700000,
          isAvailable: true,
          brand: 'Kawai',
          description: 'Đàn piano chuyên nghiệp với bàn phím Responsive Hammer Compact, âm thanh Harmonic Imaging.',
          keys: 88,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎹 Thuê Đàn Piano'),
        backgroundColor: const Color(0xFF0A1E3C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF0A1E3C),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tìm đàn phù hợp',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${pianoList.where((p) => p.isAvailable).length} đàn đang sẵn sàng',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Piano List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: pianoList.length,
                itemBuilder: (context, index) {
                  final piano = pianoList[index];
                  return _buildPianoCard(context, piano);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPianoCard(BuildContext context, PianoModel piano) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PianoDetailScreen(piano: piano),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  piano.imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: Icon(Icons.piano, size: 40, color: Colors.grey),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1E3C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        piano.brand,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0A1E3C),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Name
                    Text(
                      piano.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Keys info
                    Row(
                      children: [
                        Icon(Icons.piano_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${piano.keys} phím',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Price
                    Row(
                      children: [
                        Text(
                          '${_formatPrice(piano.pricePerMonth)}đ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0A1E3C),
                          ),
                        ),
                        Text(
                          '/tháng',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: piano.isAvailable
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PianoDetailScreen(piano: piano),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: piano.isAvailable
                              ? const Color(0xFF0A1E3C)
                              : Colors.grey[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          piano.isAvailable ? 'Thuê ngay' : 'Hết hàng',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
