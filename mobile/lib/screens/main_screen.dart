import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'rental_screen.dart';
import 'classroom_screen.dart';
import 'profile_screen.dart'; // Import ProfileScreen mới

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Danh sách các màn hình cho mỗi tab
  final List<Widget> _screens = [
    const HomeScreen(),
    const RentalScreen(),
    const ClassroomScreen(),
    const ProfileScreen(), // Dùng ProfileScreen thay vì AccountScreen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0A1E3C),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.piano),
            label: 'Thuê đàn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_call),
            label: 'Lớp học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
