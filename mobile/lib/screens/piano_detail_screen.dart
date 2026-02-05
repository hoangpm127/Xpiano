import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/piano_model.dart';

class PianoDetailScreen extends StatefulWidget {
  final PianoModel piano;

  const PianoDetailScreen({
    super.key,
    required this.piano,
  });

  @override
  State<PianoDetailScreen> createState() => _PianoDetailScreenState();
}

class _PianoDetailScreenState extends State<PianoDetailScreen> {
  final TextEditingController _addressController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // SliverAppBar với Parallax Effect
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                backgroundColor: const Color(0xFF0A1E3C),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.piano.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.piano, size: 80, color: Colors.grey),
                          );
                        },
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Nội dung chi tiết
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildMainInfo(),
                    _buildSpecsChips(),
                    _buildDescription(),
                    _buildOrderForm(),
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ],
          ),

          // Sticky Footer Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildStickyFooter(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfo() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1E3C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.piano.brand,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0A1E3C),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tên đàn - Font to, đậm
          Text(
            widget.piano.name,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          // Giá thuê - Màu xanh nổi bật
          Row(
            children: [
              Text(
                _formatPrice(widget.piano.pricePerMonth),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A1E3C),
                ),
              ),
              const Text(
                'đ/tháng',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Availability
          Row(
            children: [
              Icon(
                widget.piano.isAvailable ? Icons.check_circle : Icons.cancel,
                size: 20,
                color: widget.piano.isAvailable ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                widget.piano.isAvailable ? 'Còn hàng' : 'Hết hàng',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.piano.isAvailable ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsChips() {
    final specs = [
      {'icon': Icons.piano, 'label': '${widget.piano.keys} Phím'},
      {'icon': Icons.electrical_services, 'label': 'Digital'},
      {'icon': Icons.bluetooth, 'label': 'Bluetooth'},
      {'icon': Icons.speaker, 'label': 'Loa tích hợp'},
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: specs.map((spec) {
          return Chip(
            avatar: Icon(
              spec['icon'] as IconData,
              size: 18,
              color: const Color(0xFF0A1E3C),
            ),
            label: Text(
              spec['label'] as String,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: const Color(0xFF0A1E3C).withOpacity(0.1),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.piano.description,
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderForm() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin đặt hàng',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Địa chỉ giao hàng
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: const Color(0xFF0A1E3C),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Địa chỉ giao hàng',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Nhập địa chỉ nhận hàng...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF0A1E3C),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Chọn ngày nhận đàn
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: const Color(0xFF0A1E3C),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Ngày nhận đàn',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null
                                ? 'Chọn ngày nhận hàng'
                                : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                            style: TextStyle(
                              fontSize: 14,
                              color: _selectedDate == null
                                  ? Colors.grey[600]
                                  : Colors.black87,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Container(
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
          onPressed: widget.piano.isAvailable ? _handleDeposit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.piano.isAvailable
                ? const Color(0xFF0A1E3C)
                : Colors.grey[400],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'ĐẶT CỌC NGAY',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0A1E3C),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleDeposit() {
    // Validate
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập địa chỉ giao hàng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày nhận đàn'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Generate order ID
    final orderId = 'XPIANO-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Đặt đơn thành công!',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mã đơn: $orderId',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A1E3C),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Đàn: ${widget.piano.name}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Địa chỉ: ${_addressController.text}',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Ngày nhận: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Text(
              'Chúng tôi sẽ liên hệ bạn sớm nhất!',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to list
            },
            child: const Text('Đóng'),
          ),
        ],
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
