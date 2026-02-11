import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'login_screen.dart';
import 'admin_debug_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Longer delay to allow time to access Admin Debug screen
    await Future.delayed(const Duration(seconds: 6));
    
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;
    
    // Always go to PianoFeedScreen (supports both logged-in and guest mode)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PianoFeedScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or App Name
            const Icon(
              Icons.music_note,
              color: Color(0xFFD4AF37),
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              'XPIANO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Premium Piano Experience',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Color(0xFFD4AF37),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: const Color(0xFF2E2E2E),
        child: const Icon(Icons.admin_panel_settings, color: Color(0xFFD4AF37), size: 20),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminDebugScreen()),
          );
        },
      ),
    );
  }
}
