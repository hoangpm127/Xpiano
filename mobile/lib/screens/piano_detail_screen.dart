import 'package:flutter/material.dart';
import '../models/piano_model.dart';

class PianoDetailScreen extends StatelessWidget {
  final PianoModel piano;

  const PianoDetailScreen({
    super.key,
    required this.piano,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar với ảnh lớn
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF0A1E3C),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                piano.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.piano, size: 80, color: Colors.grey),
                  );
                },
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Nội dung chi tiết
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A1E3C).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            piano.brand,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0A1E3C),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Name
                        Text(
                          piano.name,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Price
                        Row(
                          children: [
                            Text(
                              '${_formatPrice(piano.pricePerMonth)}đ',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0A1E3C),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '/tháng',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Availability
                        Row(
                          children: [
                            Icon(
                              piano.isAvailable ? Icons.check_circle : Icons.cancel,
                              size: 20,
                              color: piano.isAvailable ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              piano.isAvailable ? 'Còn hàng' : 'Hết hàng',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: piano.isAvailable ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Divider
                        Divider(color: Colors.grey[300]),

                        const SizedBox(height: 24),

                        // Specifications
                        Text(
                          'Thông số kỹ thuật',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),

                        const SizedBox(height: 16),

                        _buildSpecRow('Số phím', '${piano.keys} phím'),
                        _buildSpecRow('Thương hiệu', piano.brand),
                        _buildSpecRow('Loại đàn', 'Piano điện tử'),
                        _buildSpecRow('Cảm ứng lực', 'Có'),

                        const SizedBox(height: 24),

                        // Description
                        Text(
                          'Mô tả',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          piano.description,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.grey[700],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Features
                        Text(
                          'Đặc điểm nổi bật',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),

                        const SizedBox(height: 12),

                        _buildFeatureItem('✅ Giao hàng miễn phí trong nội thành'),
                        _buildFeatureItem('✅ Bảo trì định kỳ miễn phí'),
                        _buildFeatureItem('✅ Hỗ trợ 24/7'),
                        _buildFeatureItem('✅ Đổi trả trong 7 ngày nếu có lỗi'),

                        const SizedBox(height: 100), // Space for bottom button
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: piano.isAvailable
                ? () {
                    _showBookingDialog(context);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: piano.isAvailable
                  ? const Color(0xFF0A1E3C)
                  : Colors.grey[400],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              piano.isAvailable ? 'XÁC NHẬN ĐẶT CỌC' : 'HẾT HÀNG',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        feature,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
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

  void _showBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận đặt cọc'),
        content: Text(
          'Bạn có muốn đặt cọc đàn "${piano.name}" với giá ${_formatPrice(piano.pricePerMonth)}đ/tháng?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đặt cọc thành công! 🎉'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A1E3C),
            ),
            child: Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}
