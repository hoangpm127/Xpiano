import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _orderCount = 0;

  @override
  void initState() {
    super.initState();
    _loadOrderCount();
  }

  Future<void> _loadOrderCount() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('orders')
            .select()
            .eq('user_id', user.id);
        
        if (mounted) {
          setState(() {
            _orderCount = (response as List).length;
          });
        }
      }
    } catch (e) {
      // Ignore error, keep count as 0
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Nền hơi xám nhẹ
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // 1. User Info Header
              _buildHeader(),

              const SizedBox(height: 24),
              
              // 2. Wallet Card
              _buildWalletCard(context),

              const SizedBox(height: 24),

              // 3. Menu List
              _buildMenuList(context),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'Guest';
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF0A1E3C), width: 2),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF0A1E3C).withOpacity(0.1),
            child: const Icon(
              Icons.person,
              size: 50,
              color: Color(0xFF0A1E3C),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          email,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A1E3C),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Thành viên Beginner',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1E3C), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A1E3C).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ví điện tử',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Icon(Icons.account_balance_wallet, color: Colors.white.withOpacity(0.8)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '1,250,000 đ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildWalletButton('Nạp tiền', Icons.add),
              const SizedBox(width: 16),
              _buildWalletButton('Lịch sử GD', Icons.history),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletButton(String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.piano,
            title: 'Đàn đang thuê',
            badge: _orderCount > 0 ? _orderCount.toString() : null,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderHistoryScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.calendar_today,
            title: 'Lịch học của tôi',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.people,
            title: 'Giới thiệu bạn bè',
            isHighlight: true, // Affiliate Highlight
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.location_on,
            title: 'Địa chỉ giao đàn',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Cài đặt chung',
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Đăng xuất',
            isDestructive: true,
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? badge,
    bool isHighlight = false,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDestructive 
                ? Colors.red.withOpacity(0.1) 
                : (isHighlight ? Colors.orange.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon, 
            color: isDestructive 
                ? Colors.red 
                : (isHighlight ? Colors.orange : const Color(0xFF0A1E3C)),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : const Color(0xFF0A1E3C),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
