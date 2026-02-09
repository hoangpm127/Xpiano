import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../services/supabase_service.dart';
import '../main.dart';
import 'teacher_dashboard_screen.dart';

class TeacherVerificationSetupScreen extends StatefulWidget {
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
  
  // Data from Step 2
  final int priceOnline;
  final int priceOffline;
  final int bundle8Sessions;
  final double bundle8Discount;
  final int bundle12Sessions;
  final double bundle12Discount;
  final bool allowTrialLesson;

  const TeacherVerificationSetupScreen({
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
    required this.priceOnline,
    required this.priceOffline,
    required this.bundle8Sessions,
    required this.bundle8Discount,
    required this.bundle12Sessions,
    required this.bundle12Discount,
    required this.allowTrialLesson,
  });

  @override
  State<TeacherVerificationSetupScreen> createState() => _TeacherVerificationSetupScreenState();
}

class _TeacherVerificationSetupScreenState extends State<TeacherVerificationSetupScreen> {
  final _idNumberController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _certificatesController = TextEditingController();
  
  final _supabaseService = SupabaseService();
  
  String? _selectedBank;
  File? _idFrontImage;
  File? _idBackImage;
  final List<File> _certificateImages = [];
  
  bool _isLoading = false;

  final List<String> _vietnameseBanks = [
    'Vietcombank',
    'VietinBank',
    'BIDV',
    'Agribank',
    'Techcombank',
    'MB Bank',
    'ACB',
    'VPBank',
    'TPBank',
    'Sacombank',
    'HDBank',
    'VIB',
    'SHB',
    'OCB',
    'MSB',
    'Nam A Bank',
    'SeABank',
    'Bac A Bank',
    'VietCapital Bank',
    'BaoViet Bank',
  ];

  Future<void> _pickImage(ImageSource source, String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      setState(() {
        if (type == 'id_front') {
          _idFrontImage = File(pickedFile.path);
        } else if (type == 'id_back') {
          _idBackImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _pickCertificateImages() async {
    if (_certificateImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tối đa 5 ảnh chứng chỉ')),
      );
      return;
    }
    
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    
    if (pickedFiles.isNotEmpty) {
      setState(() {
        for (var file in pickedFiles) {
          if (_certificateImages.length < 5) {
            _certificateImages.add(File(file.path));
          }
        }
      });
    }
  }

  void _removeCertificateImage(int index) {
    setState(() {
      _certificateImages.removeAt(index);
    });
  }

  Future<void> _submitProfile() async {
    // Validate required fields
    if (_idNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số CCCD/CMND')),
      );
      return;
    }
    
    if (_idFrontImage == null || _idBackImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chụp ảnh CCCD/CMND mặt trước và mặt sau')),
      );
      return;
    }
    
    if (_selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngân hàng')),
      );
      return;
    }
    
    if (_bankAccountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tài khoản')),
      );
      return;
    }
    
    if (_accountHolderController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên chủ tài khoản')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check video size before upload
      if (widget.videoDemoPath != null) {
        final videoFile = File(widget.videoDemoPath!);
        final videoSizeMB = await videoFile.length() / (1024 * 1024);
        if (videoSizeMB > 50) {
          if (mounted) {
            final shouldContinue = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                title: Text('Video quá lớn', style: GoogleFonts.inter(color: Colors.white)),
                content: Text(
                  'Video của bạn có kích thước ${videoSizeMB.toStringAsFixed(1)}MB (tối đa 50MB).\n\nBạn có muốn tiếp tục không upload video không?',
                  style: GoogleFonts.inter(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Hủy'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Tiếp tục không có video'),
                  ),
                ],
              ),
            );
            if (shouldContinue != true) {
              setState(() => _isLoading = false);
              return;
            }
          }
        }
      }

      // Step 1: Upload all images to Supabase Storage
      String? avatarUrl;
      String? videoDemoUrl;
      String? idFrontUrl;
      String? idBackUrl;
      List<String> certificateUrls = [];

      // Upload avatar
      if (widget.avatarPath != null) {
        final avatarFile = File(widget.avatarPath!);
        final avatarBytes = await avatarFile.readAsBytes();
        final avatarExt = widget.avatarPath!.split('.').last;
        avatarUrl = await _supabaseService.uploadImage(
          fileBytes: avatarBytes,
          fileName: 'avatar_${DateTime.now().millisecondsSinceEpoch}.$avatarExt',
          folder: 'avatars',
          timeout: const Duration(seconds: 60),
        );
      }

      // Upload video demo (with longer timeout and error handling)
      if (widget.videoDemoPath != null) {
        try {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đang upload video... Vui lòng chờ'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          
          final videoFile = File(widget.videoDemoPath!);
          final videoBytes = await videoFile.readAsBytes();
          final videoExt = widget.videoDemoPath!.split('.').last;
          
          videoDemoUrl = await _supabaseService.uploadImage(
            fileBytes: videoBytes,
            fileName: 'video_${DateTime.now().millisecondsSinceEpoch}.$videoExt',
            folder: 'videos',
            timeout: const Duration(seconds: 120), // 2 minutes for video
            maxRetries: 2,
          );
        } catch (videoError) {
          print('Video upload error: $videoError');
          
          // Ask user if they want to continue without video
          if (mounted) {
            final shouldContinue = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                title: Text('Lỗi upload video', style: GoogleFonts.inter(color: Colors.white)),
                content: Text(
                  'Không thể upload video (có thể do mạng chậm hoặc file quá lớn).\n\nBạn có muốn tiếp tục không có video không? Video có thể cập nhật sau.',
                  style: GoogleFonts.inter(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Hủy'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Tiếp tục không có video'),
                  ),
                ],
              ),
            );
            
            if (shouldContinue != true) {
              setState(() => _isLoading = false);
              return;
            }
            // Continue without video
            videoDemoUrl = null;
          }
        }
      }

      // Upload ID card front
      if (_idFrontImage != null) {
        final idFrontBytes = await _idFrontImage!.readAsBytes();
        final idFrontExt = _idFrontImage!.path.split('.').last;
        idFrontUrl = await _supabaseService.uploadImage(
          fileBytes: idFrontBytes,
          fileName: 'id_front_${DateTime.now().millisecondsSinceEpoch}.$idFrontExt',
          folder: 'id_cards',
        );
      }

      // Upload ID card back
      if (_idBackImage != null) {
        final idBackBytes = await _idBackImage!.readAsBytes();
        final idBackExt = _idBackImage!.path.split('.').last;
        idBackUrl = await _supabaseService.uploadImage(
          fileBytes: idBackBytes,
          fileName: 'id_back_${DateTime.now().millisecondsSinceEpoch}.$idBackExt',
          folder: 'id_cards',
        );
      }

      // Upload certificate images
      for (int i = 0; i < _certificateImages.length; i++) {
        final certFile = _certificateImages[i];
        final certBytes = await certFile.readAsBytes();
        final certExt = certFile.path.split('.').last;
        final certUrl = await _supabaseService.uploadImage(
          fileBytes: certBytes,
          fileName: 'cert_${i}_${DateTime.now().millisecondsSinceEpoch}.$certExt',
          folder: 'certificates',
        );
        certificateUrls.add(certUrl);
      }

      // Step 2: Combine all data from 3 steps
      final profileData = {
        // Step 1: Basic Info
        'full_name': widget.fullName,
        'specializations': widget.specializations.toList(),
        'years_experience': widget.yearsExperience,
        'bio': widget.bio,
        'teach_online': widget.teachOnline,
        'teach_offline': widget.teachOffline,
        'locations': widget.locations.toList(),
        
        // Step 2: Pricing
        'price_online': widget.priceOnline,
        'price_offline': widget.priceOffline,
        'bundle_8_sessions': widget.bundle8Sessions,
        'bundle_8_discount': widget.bundle8Discount,
        'bundle_12_sessions': widget.bundle12Sessions,
        'bundle_12_discount': widget.bundle12Discount,
        'allow_trial_lesson': widget.allowTrialLesson,
        
        // Step 3: Verification
        'id_number': _idNumberController.text.trim(),
        'bank_name': _selectedBank,
        'bank_account': _bankAccountController.text.trim(),
        'account_holder': _accountHolderController.text.trim().toUpperCase(),
        'certificates_description': _certificatesController.text.trim(),
        
        // URLs
        'avatar_url': avatarUrl,
        'video_demo_url': videoDemoUrl,
        'id_front_url': idFrontUrl,
        'id_back_url': idBackUrl,
        'certificate_urls': certificateUrls,
        
        // Status
        'verification_status': 'pending',
      };

      // Step 3: Save to Supabase teacher_profiles table
      await _supabaseService.createTeacherProfile(profileData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Gửi hồ sơ thành công! Chờ duyệt trong 72h'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Navigate to Teacher Dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const TeacherDashboardScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section 1: Identity
                  _buildSectionHeader('Thông tin định danh'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _idNumberController,
                    label: 'Số CCCD / CMND *',
                    placeholder: 'Nhập số CCCD hoặc CMND',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildIdPhotoUpload(),
                  
                  const SizedBox(height: 32),
                  
                  // Section 2: Banking
                  _buildSectionHeader('Tài khoản ngân hàng'),
                  const SizedBox(height: 16),
                  _buildBankDropdown(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _bankAccountController,
                    label: 'Số tài khoản *',
                    placeholder: 'Nhập số tài khoản ngân hàng',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _accountHolderController,
                    label: 'Tên chủ tài khoản *',
                    placeholder: 'NGUYEN VAN A',
                    textCapitalization: TextCapitalization.characters,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Section 3: Certificates
                  _buildSectionHeader('Bằng cấp & Thành tích'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _certificatesController,
                    label: 'Mô tả bằng cấp',
                    placeholder: 'Mô tả ngắn gọn bằng cấp, giải thưởng âm nhạc của bạn...',
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  _buildCertificateUpload(),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
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
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Xác thực hồ sơ',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Bước 3/3',
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.3),
            ),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBankDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn ngân hàng *',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedBank,
            dropdownColor: const Color(0xFF1E1E1E),
            decoration: InputDecoration(
              hintText: 'Chọn ngân hàng',
              hintStyle: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.3),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37)),
            style: GoogleFonts.inter(color: Colors.white),
            items: _vietnameseBanks.map((bank) {
              return DropdownMenuItem(
                value: bank,
                child: Text(bank),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedBank = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIdPhotoUpload() {
    return Row(
      children: [
        Expanded(
          child: _buildPhotoBox(
            label: 'Mặt trước',
            image: _idFrontImage,
            onTap: () => _pickImage(ImageSource.gallery, 'id_front'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPhotoBox(
            label: 'Mặt sau',
            image: _idBackImage,
            onTap: () => _pickImage(ImageSource.gallery, 'id_back'),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoBox({
    required String label,
    required File? image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFD4AF37),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  image,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt,
                    color: Color(0xFFD4AF37),
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCertificateUpload() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickCertificateImages,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD4AF37),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.insert_drive_file_outlined,
                  color: Color(0xFFD4AF37),
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  'Tải ảnh chứng chỉ / Bằng khen',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'JPG/PNG • Tối đa 5 ảnh',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Display selected images
        if (_certificateImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _certificateImages.asMap().entries.map((entry) {
              final index = entry.key;
              final image = entry.value;
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      image,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeCertificateImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 8),
              Text(
                'Hồ sơ sẽ được duyệt trong vòng 72 giờ làm việc.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitProfile,
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
                      'Hoàn tất & Gửi duyệt',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _idNumberController.dispose();
    _bankAccountController.dispose();
    _accountHolderController.dispose();
    _certificatesController.dispose();
    super.dispose();
  }
}
