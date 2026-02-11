import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'teacher_verification_setup_screen.dart';

class TeacherPricingSetupScreen extends StatefulWidget {
  // Data from Step 1
  final String fullName;
  final String? avatarPath;
  final Set<String> specializations;
  final int yearsExperience;
  final String bio;
  final bool teachOnline;
  final bool teachOffline;
  final Set<String> locations;
  final String? videoDemoPath;

  const TeacherPricingSetupScreen({
    super.key,
    required this.fullName,
    this.avatarPath,
    required this.specializations,
    required this.yearsExperience,
    required this.bio,
    required this.teachOnline,
    required this.teachOffline,
    required this.locations,
    this.videoDemoPath,
  });

  @override
  State<TeacherPricingSetupScreen> createState() => _TeacherPricingSetupScreenState();
}

class _TeacherPricingSetupScreenState extends State<TeacherPricingSetupScreen> {
  // Pricing data
  int _priceOnline = 250000; // 250k VND default
  int _priceOffline = 350000; // 350k VND default
  
  // Bundle packages
  int _bundle8Sessions = 8;
  double _bundle8Discount = 10; // 10%
  
  int _bundle12Sessions = 12;
  double _bundle12Discount = 15; // 15%
  
  bool _allowTrialLesson = true; // Default enabled
  
  bool _isLoading = false;

  void _showEditPriceDialog({
    required String title,
    required int currentPrice,
    required Function(int) onSave,
  }) {
    final controller = TextEditingController(text: currentPrice.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Giá (VNĐ)',
            labelStyle: GoogleFonts.inter(color: Colors.white70),
            suffixText: 'đ',
            suffixStyle: GoogleFonts.inter(color: const Color(0xFFD4AF37)),
            filled: true,
            fillColor: const Color(0xFF121212),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4AF37)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              final newPrice = int.tryParse(controller.text);
              if (newPrice != null && newPrice > 0) {
                onSave(newPrice);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập giá hợp lệ')),
                );
              }
            },
            child: Text(
              'Lưu',
              style: GoogleFonts.inter(
                color: const Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditBundleDialog({
    required String title,
    required int currentSessions,
    required double currentDiscount,
    required Function(int, double) onSave,
  }) {
    final sessionsController = TextEditingController(text: currentSessions.toString());
    final discountController = TextEditingController(text: currentDiscount.toInt().toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: sessionsController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Số buổi',
                labelStyle: GoogleFonts.inter(color: Colors.white70),
                suffixText: 'buổi',
                filled: true,
                fillColor: const Color(0xFF121212),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: discountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Giảm giá',
                labelStyle: GoogleFonts.inter(color: Colors.white70),
                suffixText: '%',
                suffixStyle: GoogleFonts.inter(color: const Color(0xFFD4AF37)),
                filled: true,
                fillColor: const Color(0xFF121212),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              final sessions = int.tryParse(sessionsController.text);
              final discount = double.tryParse(discountController.text);
              if (sessions != null && sessions > 0 && discount != null && discount >= 0) {
                onSave(sessions, discount);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập thông tin hợp lệ')),
                );
              }
            },
            child: Text(
              'Lưu',
              style: GoogleFonts.inter(
                color: const Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmAndContinue() {
    // Navigate to Step 3 with all data from Step 1 & 2
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherVerificationSetupScreen(
          // Step 1 data
          fullName: widget.fullName,
          avatarPath: widget.avatarPath,
          specializations: widget.specializations,
          yearsExperience: widget.yearsExperience,
          bio: widget.bio,
          teachOnline: widget.teachOnline,
          teachOffline: widget.teachOffline,
          locations: widget.locations,
          videoDemoPath: widget.videoDemoPath,
          // Step 2 data
          priceOnline: _priceOnline,
          priceOffline: _priceOffline,
          bundle8Sessions: _bundle8Sessions,
          bundle8Discount: _bundle8Discount,
          bundle12Sessions: _bundle12Sessions,
          bundle12Discount: _bundle12Discount,
          allowTrialLesson: _allowTrialLesson,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Online 1-1 Card
                  _buildPricingCard(
                    title: '1-1 (Online)',
                    price: _priceOnline,
                    badge: 'Phổ biến',
                    badgeColor: const Color(0xFFD4AF37),
                    badgeTextColor: Colors.black,
                    onEdit: () {
                      _showEditPriceDialog(
                        title: 'Chỉnh sửa giá Online',
                        currentPrice: _priceOnline,
                        onSave: (newPrice) => setState(() => _priceOnline = newPrice),
                      );
                    },
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  // Offline 1-1 Card
                  _buildPricingCard(
                    title: '1-1 (Offline)',
                    price: _priceOffline,
                    subtitle: 'Tại nhà / studio',
                    onEdit: () {
                      _showEditPriceDialog(
                        title: 'Chỉnh sửa giá Offline',
                        currentPrice: _priceOffline,
                        onSave: (newPrice) => setState(() => _priceOffline = newPrice),
                      );
                    },
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  // Section Title
                  Text(
                    'Gói học tiết kiệm',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Bundle 8 Sessions
                  _buildBundleCard(
                    title: 'Gói $_bundle8Sessions buổi',
                    discount: _bundle8Discount,
                    subtitle: 'Tiết kiệm cho lịch học đều',
                    onEdit: () {
                      _showEditBundleDialog(
                        title: 'Chỉnh sửa gói 8 buổi',
                        currentSessions: _bundle8Sessions,
                        currentDiscount: _bundle8Discount,
                        onSave: (sessions, discount) {
                          setState(() {
                            _bundle8Sessions = sessions;
                            _bundle8Discount = discount;
                          });
                        },
                      );
                    },
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
                  
                  const SizedBox(height: 16),
                  
                  // Bundle 12 Sessions
                  _buildBundleCard(
                    title: 'Gói $_bundle12Sessions buổi',
                    discount: _bundle12Discount,
                    subtitle: 'Phù hợp mục tiêu dài hạn',
                    onEdit: () {
                      _showEditBundleDialog(
                        title: 'Chỉnh sửa gói 12 buổi',
                        currentSessions: _bundle12Sessions,
                        currentDiscount: _bundle12Discount,
                        onSave: (sessions, discount) {
                          setState(() {
                            _bundle12Sessions = sessions;
                            _bundle12Discount = discount;
                          });
                        },
                      );
                    },
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  // Trial Lesson Toggle
                  _buildTrialLessonCard().animate().fadeIn(delay: 500.ms),
                  
                  const SizedBox(height: 100), // Space for footer
                ],
              ),
            ),
          ),
          
          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Text(
              'Giá & gói dạy',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          // Info Icon
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.white.withOpacity(0.5),
              size: 22,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    'Thông tin giá',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    'Đặt giá phù hợp để thu hút học viên. Bạn có thể thay đổi bất cứ lúc nào trong phần cài đặt.',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Đã hiểu',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(width: 8),
          
          // Step Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Bước 2/3',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildPricingCard({
    required String title,
    required int price,
    String? subtitle,
    String? badge,
    Color? badgeColor,
    Color? badgeTextColor,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // Title
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              
              // Badge (if provided)
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor ?? const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: badgeTextColor ?? Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              
              // Edit Button
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 14),
                label: Text(
                  'Chỉnh sửa',
                  style: GoogleFonts.inter(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Price Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}đ',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '/ 60 phút',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
          
          // Subtitle
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBundleCard({
    required String title,
    required double discount,
    required String subtitle,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // Title
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              
              // Discount Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.5),
                  ),
                ),
                child: Text(
                  'Giảm ${discount.toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Edit Button
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 14),
                label: Text(
                  'Chỉnh sửa',
                  style: GoogleFonts.inter(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrialLessonCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cho phép học thử 1 buổi',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Học thử giúp tăng tỉ lệ nhận lớp',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Switch
          Switch(
            value: _allowTrialLesson,
            onChanged: (value) => setState(() => _allowTrialLesson = value),
            activeColor: const Color(0xFFD4AF37),
            activeTrackColor: const Color(0xFFD4AF37).withOpacity(0.3),
            inactiveThumbColor: Colors.white.withOpacity(0.5),
            inactiveTrackColor: Colors.white.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Disclaimer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 6),
              Text(
                'Phí đã hiển thị trong báo cáo thu nhập',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Primary Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _confirmAndContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Xác nhận',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Bạn có thể thay đổi bất cứ lúc nào',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
