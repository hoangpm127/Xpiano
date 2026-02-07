import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/supabase_service.dart';
import '../main.dart'; // Import to navigate to Home
// import 'teacher_onboarding_screen.dart'; // Can be used later if teacher specific flow needed
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
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
  
  // 0: Guest/Student (Khách/Học viên), 1: Teacher (Giáo viên)
  int _selectedRoleIndex = 0; 

  Future<void> _handleRegister() async {
    // Validate inputs
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        (_otpSent && _otpController.text.isEmpty)) {
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
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // NOTE: Using email signup for now as Supabase default.
      final fakeEmail = '${_phoneController.text.trim()}@spiano.app';
      
      // Determine role based on selected tab
      final role = _selectedRoleIndex == 0 ? 'student' : 'teacher';

      await _supabaseService.signUp(
        email: fakeEmail, 
        password: _passwordController.text,
        fullName: _nameController.text,
        role: role, // Pass the correct role
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng ký tài khoản ${role == 'teacher' ? 'Giáo viên' : 'Học viên'} thành công!')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PianoFeedScreen()),
          (route) => false,
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

  void _sendOtp() {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số điện thoại')),
      );
      return;
    }
    setState(() => _otpSent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mã xác thực đã gửi (Giả lập: 1234)')),
    );
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
                  
                  _buildTextField(
                    controller: _dobController,
                    hint: 'Ngày sinh (DD/MM/YYYY)',
                    icon: Icons.calendar_today_outlined,
                    keyboardType: TextInputType.datetime,
                  ).animate().fadeIn(delay: 350.ms),

                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    controller: _phoneController,
                    hint: 'Số điện thoại',
                    icon: Icons.phone_android,
                    keyboardType: TextInputType.phone,
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
                          onPressed: _sendOtp,
                          child: Text(
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
