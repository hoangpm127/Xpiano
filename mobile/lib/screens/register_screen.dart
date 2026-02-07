import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/email_service.dart';
import '../main.dart';
import 'teacher_profile_setup_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _supabaseService = SupabaseService();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreedToTerms = false;
  bool _otpSent = false;
  
  int _selectedRoleIndex = 0; 
  DateTime? _selectedDate;
  String? _generatedOtp; // Store generated OTP
  DateTime? _otpSentTime; // Store OTP sent time for timeout

  Future<void> _handleRegister() async {
    // Validate inputs
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _otpController.text.isEmpty) { // OTP is mandatory
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không khớp')),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đồng ý với Điều khoản & Chính sách')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final userOtp = _otpController.text.trim();
      final password = _passwordController.text;
      final role = _selectedRoleIndex == 0 ? 'student' : 'teacher';

      // 1. Verify OTP first (Must be sent before)
      if (!_otpSent || _generatedOtp == null || _otpSentTime == null) {
          throw Exception('Vui lòng bấm "Gửi mã" trước');
      }
      
      // Check OTP timeout (5 minutes)
      final now = DateTime.now();
      final difference = now.difference(_otpSentTime!);
      if (difference.inMinutes > 5) {
        throw Exception('Mã xác thực đã hết hạn. Vui lòng gửi lại!');
      }

      // Check OTP match
      if (userOtp != _generatedOtp) {
        throw Exception('Mã xác thực không đúng');
      }
      
      // 2. Check if email already exists in Supabase
      // We'll catch this in the AuthException handler
      
      // 3. Register with Supabase (OTP already verified)
      final response = await _supabaseService.signUp(
        email: email, 
        password: password,
        fullName: _nameController.text,
        role: role,
      );
      
      // Check if signup was successful
      if (response.user == null) {
        throw Exception('Đăng ký thất bại. Vui lòng thử lại!');
      }
      
      // Auto-login after successful signup
      // Since OTP is verified, we can log them in immediately

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng ký tài khoản ${role == 'teacher' ? 'Giáo viên' : 'Học viên'} thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to Teacher Profile Setup if teacher, otherwise go to feed
        if (role == 'teacher') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const TeacherProfileSetupScreen()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const PianoFeedScreen()),
            (route) => false,
          );
        }
      }
    } on AuthException catch (e) {
      // Handle Supabase Auth specific errors
      String errorMessage = 'Lỗi đăng ký';
      
      print('AuthException: ${e.message}'); // Debug
      
      if (e.message.contains('User already registered') || 
          e.message.contains('already been registered') ||
          e.message.contains('already exists')) {
        errorMessage = '❌ Email này đã được sử dụng!\n\nVui lòng sử dụng email khác hoặc đăng nhập nếu bạn đã có tài khoản.';
      } else if (e.message.contains('Invalid email') || e.message.contains('invalid_email')) {
        errorMessage = 'Email không hợp lệ! Vui lòng nhập đúng định dạng email.';
      } else if (e.message.contains('Password') || e.message.contains('password')) {
        errorMessage = 'Mật khẩu phải có ít nhất 6 ký tự!';
      } else if (e.message.contains('rate limit') || e.message.contains('too many')) {
        errorMessage = 'Quá nhiều yêu cầu. Vui lòng thử lại sau 1 phút!';
      } else if (e.message.contains('Email not confirmed')) {
        // This shouldn't happen with our flow, but just in case
        errorMessage = 'Lỗi xác thực. Vui lòng thử lại!';
      } else {
        errorMessage = 'Lỗi: ${e.message}';
      }
      
      if (mounted) {
        // Show dialog for duplicate email (more prominent)
        if (errorMessage.contains('đã được sử dụng')) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Email Đã Tồn Tại',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: Text(
                'Email này đã được sử dụng để đăng ký tài khoản.\n\nVui lòng:\n• Sử dụng email khác\n• Hoặc đăng nhập nếu bạn đã có tài khoản',
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
                    'Thử Email Khác',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFD4AF37),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Đăng Nhập',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Show snackbar for other errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Email hợp lệ')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Generate OTP và gửi (check duplicate sẽ được xử lý khi signUp)
      final random = Random();
      final otp = (100000 + random.nextInt(900000)).toString(); // Generates 6 digit code
      _generatedOtp = otp; // Save for verification
      _otpSentTime = DateTime.now(); // Save sent time
      
      // Use EmailService with custom SMTP
      await EmailService.sendOtp(email, otp);
      
      setState(() => _otpSent = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mã xác thực đã gửi về Email (Kiểm tra cả Spam)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000), // Default to year 2000
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37), // Gold
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1E1E1E),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Format dd/MM/yyyy
        _dobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Color(0xFF1E1E1E),
              Color(0xFF121212),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header
                  Text(
                    'Đăng ký tài khoản',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: const Color(0xFFD4AF37),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Tạo tài khoản để tham gia cộng đồng Spiano',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 32),

                  // 2. Role Switcher (New)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _buildRoleTab('Khách/Học viên', 0),
                        _buildRoleTab('Giáo viên', 1),
                      ],
                    ),
                  ).animate().fadeIn(delay: 250.ms),

                  const SizedBox(height: 24),

                  // 3. Form Fields
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Họ và tên',
                    icon: Icons.person_outline,
                  ).animate().fadeIn(delay: 300.ms),
                  
                  const SizedBox(height: 16),
                  
                  // Date Picker Field
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer( // Prevent manual editing
                      child: _buildTextField(
                        controller: _dobController,
                        hint: 'Ngày sinh (DD/MM/YYYY)',
                        icon: Icons.calendar_today_outlined,
                      ),
                    ),
                  ).animate().fadeIn(delay: 350.ms),

                  const SizedBox(height: 16),
                  
                  // Email Field (Changed from Phone)
                  _buildTextField(
                    controller: _emailController,
                    hint: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 16),

                  // OTP Field Group
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _otpController,
                          hint: 'Mã xác thực',
                          icon: Icons.security,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextButton(
                          onPressed: _isLoading ? null : _sendOtp,
                          child: _isLoading && !_otpSent 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD4AF37)))
                              : Text(
                            _otpSent ? 'Gửi lại' : 'Gửi mã',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 450.ms),

                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Mật khẩu',
                    icon: Icons.lock_outline,
                    isPassword: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white54,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _confirmPasswordController,
                    hint: 'Nhập lại mật khẩu',
                    icon: Icons.lock_outline,
                    isPassword: !_isConfirmPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white54,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                    ),
                  ).animate().fadeIn(delay: 550.ms),

                  const SizedBox(height: 24),

                  // 3. Terms Checkbox
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _agreedToTerms,
                          activeColor: const Color(0xFFD4AF37),
                          checkColor: Colors.black,
                          side: BorderSide(color: Colors.white.withOpacity(0.3), width: 2),
                          onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tôi đồng ý với Điều khoản & Chính sách',
                          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 24),

                  // 4. Register Button
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE6C86E), Color(0xFFBF953F)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                          : Text(
                              'ĐĂNG KÝ',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                letterSpacing: 1.0,
                              ),
                            ),
                    ),
                  ).animate().fadeIn(delay: 700.ms).scale(),

                  const SizedBox(height: 32),

                  // 5. Footer: Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Đã có tài khoản? ',
                        style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          'Đăng nhập',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTab(String title, int index) {
    final isSelected = _selectedRoleIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRoleIndex = index),
        child: AnimatedContainer(
          duration: 300.ms,
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF333333) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5), width: 1) : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: isSelected ? const Color(0xFFD4AF37) : Colors.white54,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.white24, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white54, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD4AF37)),
        ),
      ),
    );
  }
}
