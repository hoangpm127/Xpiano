import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'classroom_screen.dart'; // Navigaton đến ClassroomScreen

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header
                _buildHeader(),
                
                const SizedBox(height: 32),
                
                // 2. Progress Card (Biểu đồ)
                _buildProgressCard(context),
                
                const SizedBox(height: 32),
                
                // 3. Quick Actions (Lối tắt)
                _buildQuickActions(context),
                
                const SizedBox(height: 32),
                
                // 4. Upcoming Lesson (Nhắc lịch)
                _buildUpcomingLesson(context),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets Components ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chào, Học viên!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A1E3C),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sẵn sàng cho buổi học hôm nay?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Notification Bell
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_outlined, color: Color(0xFF0A1E3C)),
            ),
            const SizedBox(width: 12),
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF0A1E3C),
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'), // Dummy Avatar
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1E3C), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A1E3C).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Chart
          Padding(
            padding: const EdgeInsets.only(top: 60, bottom: 20, left: 0, right: 0),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(1, 1),
                      FlSpot(2, 4),
                      FlSpot(3, 2),
                      FlSpot(4, 5),
                      FlSpot(5, 4),
                      FlSpot(6, 6),
                    ],
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueAccent.withOpacity(0.5),
                        Colors.white.withOpacity(0.8),
                      ],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.withOpacity(0.2),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Foreground Text
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chuỗi luyện tập',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '12',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'ngày',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '85% Hoàn thành',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lối tắt',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A1E3C),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionButton(
              context, 
              icon: Icons.play_arrow_rounded, 
              label: 'Học ngay', 
              color: Colors.orange,
              onTap: () {
                // TODO: Navigate to Learning
              }
            ),
            _buildActionButton(
              context, 
              icon: Icons.piano, 
              label: 'Mượn đàn', 
              color: Colors.purple,
              onTap: () {
                // Switch to Rental Tab (Logic can use Provider/bloc later)
                // For now just print
                debugPrint("Navigate to Rental Tab");
              }
            ),
            _buildActionButton(
              context, 
              icon: Icons.search, 
              label: 'Tìm GV', 
              color: Colors.green,
               onTap: () {
                 // TODO: Find Teacher
               }
            ),
            _buildActionButton(
              context, 
              icon: Icons.account_balance_wallet, 
              label: 'Nạp ví', 
              color: Colors.blue,
              onTap: () {
                // TODO: Payment Flow
              }
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80, 
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A4A4A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingLesson(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Buổi học sắp tới',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A1E3C),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://i.pravatar.cc/150?img=5',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '19:00 - Hôm nay',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Giáo viên: Cô Linh',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0A1E3C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Piano Cơ bản - Bài 4',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Navigate to Classroom
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ClassroomScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A8FF),
                  foregroundColor: Colors.white,
                  shadowColor: const Color(0xFF00A8FF).withOpacity(0.4),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Vào lớp'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
