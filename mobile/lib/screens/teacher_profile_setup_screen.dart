import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../features/common/stub_helper.dart';
import 'teacher_pricing_setup_screen.dart';

class TeacherProfileSetupScreen extends StatefulWidget {
  const TeacherProfileSetupScreen({super.key});

  @override
  State<TeacherProfileSetupScreen> createState() => _TeacherProfileSetupScreenState();
}

class _TeacherProfileSetupScreenState extends State<TeacherProfileSetupScreen> {
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  
  File? _avatarImage;
  File? _videoDemo;
  
  final List<String> _specializations = ['Piano', 'Lý thuyết nhạc', 'Thanh nhạc'];
  final Set<String> _selectedSpecializations = {};
  
  int _yearsExperience = 0;
  
  bool _teachOnline = false;
  bool _teachOffline = false;
  
  final List<String> _availableLocations = [
    'Cầu Giấy', 'Ba Đình', 'Đống Đa', 'Hoàn Kiếm', 
    'Hai Bà Trưng', 'Thanh Xuân', 'Tây Hồ'
  ];
  final Set<String> _selectedLocations = {};
  
  bool _isLoading = false;

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    );
    
    if (pickedFile != null) {
      // Check file size (50MB max)
      final file = File(pickedFile.path);
      final fileSize = await file.length();
      if (fileSize > 50 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video quá lớn! Tối đa 50MB')),
          );
        }
        return;
      }
      
      setState(() {
        _videoDemo = file;
      });
    }
  }

  void _saveAndContinue() {
    // Validate
    if (_fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập họ và tên')),
      );
      return;
    }
    
    if (_selectedSpecializations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 chuyên môn')),
      );
      return;
    }
    
    if (!_teachOnline && !_teachOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn hình thức dạy')),
      );
      return;
    }
    
    // Navigate to Step 2 with data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherPricingSetupScreen(
          fullName: _fullNameController.text.trim(),
          avatarPath: _avatarImage?.path,
          specializations: _selectedSpecializations,
          yearsExperience: _yearsExperience,
          bio: _bioController.text.trim(),
          teachOnline: _teachOnline,
          teachOffline: _teachOffline,
          locations: _selectedLocations,
          videoDemoPath: _videoDemo?.path,
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
          // 1. Sticky Header
          _buildHeader(),
          
          // 2. Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Avatar Upload
                  _buildAvatarSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Full Name
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Họ và tên',
                    placeholder: 'Nhập họ và tên của bạn',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Specialization
                  _buildSpecializationSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Experience
                  _buildExperienceSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Bio
                  _buildBioSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Teaching Mode
                  _buildTeachingModeSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Location
                  _buildLocationSection(),
                  
                  const SizedBox(height: 32),
                  
                  // Video Demo
                  _buildVideoDemoSection(),
                  
                  const SizedBox(height: 100), // Space for sticky footer
                ],
              ),
            ),
          ),
          
          // 3. Sticky Footer
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
              'Tạo hồ sơ giáo viên',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          // Step Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Bước 1/3',
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

  Widget _buildAvatarSection() {
    return Column(
      children: [
        // Avatar Circle
        GestureDetector(
          onTap: _pickAvatar,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2A2A2A),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: _avatarImage != null
                ? ClipOval(
                    child: Image.file(
                      _avatarImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.person_outline,
                    size: 50,
                    color: Colors.white.withOpacity(0.3),
                  ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Upload Button
        OutlinedButton.icon(
          onPressed: _pickAvatar,
          icon: const Icon(Icons.upload, size: 18),
          label: Text(
            'Tải ảnh',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFD4AF37),
            side: const BorderSide(color: Color(0xFFD4AF37)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Helper Text
        Text(
          'Ảnh rõ mặt, nền sáng',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    int maxLines = 1,
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecializationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chuyên môn',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _specializations.map((spec) {
            final isSelected = _selectedSpecializations.contains(spec);
            return ChoiceChip(
              label: Text(spec),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSpecializations.add(spec);
                  } else {
                    _selectedSpecializations.remove(spec);
                  }
                });
              },
              labelStyle: GoogleFonts.inter(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w500,
              ),
              backgroundColor: const Color(0xFF2A2A2A),
              selectedColor: const Color(0xFFD4AF37),
              side: BorderSide(
                color: isSelected 
                    ? const Color(0xFFD4AF37) 
                    : Colors.white.withOpacity(0.2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExperienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kinh nghiệm',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minus Button
            IconButton(
              onPressed: () {
                if (_yearsExperience > 0) {
                  setState(() => _yearsExperience--);
                }
              },
              icon: const Icon(Icons.remove_circle_outline),
              color: const Color(0xFFD4AF37),
              iconSize: 36,
            ),
            
            const SizedBox(width: 24),
            
            // Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                ),
              ),
              child: Text(
                '$_yearsExperience năm',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(width: 24),
            
            // Plus Button
            IconButton(
              onPressed: () {
                if (_yearsExperience < 50) {
                  setState(() => _yearsExperience++);
                }
              },
              icon: const Icon(Icons.add_circle_outline),
              color: const Color(0xFFD4AF37),
              iconSize: 36,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giới thiệu ngắn',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _bioController,
          maxLines: 5,
          maxLength: 300,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Vui lòng viết vài câu về bản thân, phong cách dạy...',
            hintStyle: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.3),
              fontSize: 13,
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
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildTeachingModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hình thức dạy',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Online
            Expanded(
              child: _buildModeToggle(
                label: 'Online',
                icon: Icons.laptop_mac,
                isSelected: _teachOnline,
                onTap: () => setState(() => _teachOnline = !_teachOnline),
              ),
            ),
            const SizedBox(width: 12),
            // Offline
            Expanded(
              child: _buildModeToggle(
                label: 'Offline',
                icon: Icons.location_on,
                isSelected: _teachOffline,
                onTap: () => setState(() => _teachOffline = !_teachOffline),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Bạn có thể nhận cả Online & Offline',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildModeToggle({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37).withOpacity(0.15) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.5),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? const Color(0xFFD4AF37) : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Khu vực dạy',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._availableLocations.map((location) {
              final isSelected = _selectedLocations.contains(location);
              return FilterChip(
                label: Text(location),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedLocations.add(location);
                    } else {
                      _selectedLocations.remove(location);
                    }
                  });
                },
                labelStyle: GoogleFonts.inter(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 13,
                ),
                backgroundColor: const Color(0xFF2A2A2A),
                selectedColor: const Color(0xFFD4AF37),
                side: BorderSide(
                  color: isSelected 
                      ? const Color(0xFFD4AF37) 
                      : Colors.white.withOpacity(0.2),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }),
            // Add Location Button
            ActionChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 16, color: Color(0xFFD4AF37)),
                  const SizedBox(width: 4),
                  Text(
                    'Thêm',
                    style: GoogleFonts.inter(color: const Color(0xFFD4AF37)),
                  ),
                ],
              ),
              onPressed: () {
                openStub(
                  context,
                  'Thêm khu vực dạy',
                  'Tính năng thêm khu vực tùy chỉnh sẽ được mở trong bản tiếp theo.',
                );
              },
              backgroundColor: const Color(0xFF2A2A2A),
              side: const BorderSide(color: Color(0xFFD4AF37)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVideoDemoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Video dạy thử',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickVideo,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD4AF37),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                    ),
                  ),
                  child: const Icon(
                    Icons.videocam,
                    color: Colors.black,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _videoDemo != null 
                      ? '✓ Video đã chọn' 
                      : 'Tải video dạy thử 30-60s',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _videoDemo != null 
                        ? const Color(0xFFD4AF37) 
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'MP4/MOV • Tối đa 50MB',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                if (_videoDemo != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _videoDemo!.path.split('/').last,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
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
          // Primary Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveAndContinue,
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
                      'Lưu & tiếp tục',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Có thể chỉnh sửa sau',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
