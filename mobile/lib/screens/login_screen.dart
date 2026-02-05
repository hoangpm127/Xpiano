import 'package:flutter/material.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _logoAnimation;

  @override
  void initState() {
    super.initState();
    
    // Logo fade-in animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A1E3C), // Xanh đậm
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  
                  // Logo với animation
                  FadeTransition(
                    opacity: _logoAnimation,
                    child: ScaleTransition(
                      scale: _logoAnimation,
                      child: _buildLogo(),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Form đăng nhập
                  _buildLoginForm(),
                  
                  const SizedBox(height: 32),
                  
                  // Social login
                  _buildSocialLogin(),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.piano,
            size: 80,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'XPIANO',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hệ sinh thái âm nhạc',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Số điện thoại
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _phoneController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Số điện thoại',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.phone, color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Mật khẩu
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _passwordController,
            style: const TextStyle(color: Colors.white),
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: 'Mật khẩu',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: const Icon(Icons.lock, color: Colors.white70),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Nút đăng nhập
        Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF00A8FF), // Xanh sáng
                Color(0xFF0A7AFF),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00A8FF).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'ĐĂNG NHẬP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Quên mật khẩu
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Chức năng đang phát triển'),
              ),
            );
          },
          child: Text(
            'Quên mật khẩu?',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Hoặc đăng nhập bằng',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.3))),
          ],
        ),

        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: Icons.g_mobiledata,
              label: 'Google',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đăng nhập Google - Coming soon'),
                  ),
                );
              },
            ),

            const SizedBox(width: 24),

            _buildSocialButton(
              icon: Icons.apple,
              label: 'Apple',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đăng nhập Apple - Coming soon'),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Đăng ký
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Chưa có tài khoản? ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chức năng đăng ký đang phát triển'),
                  ),
                );
              },
              child: const Text(
                'Đăng ký',
                style: TextStyle(
                  color: Color(0xFF00A8FF),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    // Validate
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập số điện thoại'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập mật khẩu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Logic giả: Đăng nhập thành công
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đăng nhập thành công! 🎉'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to MainScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
  }
}
