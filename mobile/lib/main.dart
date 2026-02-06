import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://pjgjusdmzxrhgiptfvbg.supabase.co',
    anonKey: 'sb_publishable_GMnCRFvRGqElGLerTiE-3g_YpGm-KoW',
  );

  runApp(const XpianoApp());
}

class XpianoApp extends StatelessWidget {
  const XpianoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xpiano',
      debugShowCheckedModeBanner: false, // Tắt chữ DEBUG
      theme: ThemeData(
        primaryColor: const Color(0xFF0A1E3C), // Màu xanh đậm
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A1E3C),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: _getInitialScreen(),
    );
  }

  Widget _getInitialScreen() {
    // Check if user is already logged in
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      return const MainScreen();
    }
    return const LoginScreen();
  }
}
