import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/supabase_service.dart';
import 'login_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color backgroundLight = Color(0xFFF7F7F7);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE6E6E6);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B6B6B);

  final SupabaseService _supabaseService = SupabaseService();

  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _smsEnabled = false;

  @override
  Widget build(BuildContext context) {
    final user = _supabaseService.currentUser;
    final email = user?.email ?? 'guest@xpiano.app';

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _buildAccountCard(email),
                  const SizedBox(height: 14),
                  _buildSectionTitle('Tài khoản'),
                  const SizedBox(height: 8),
                  _buildSettingTile(
                    icon: Icons.lock_outline,
                    title: 'Đổi mật khẩu',
                    subtitle: 'Cập nhật mật khẩu đăng nhập',
                    onTap: () => _showSimpleMessage('Mở màn hình đổi mật khẩu'),
                  ),
                  _buildSettingTile(
                    icon: Icons.account_balance_outlined,
                    title: 'Liên kết ngân hàng',
                    subtitle: 'Quản lý tài khoản nhận tiền',
                    onTap: () =>
                        _showSimpleMessage('Mở quản lý liên kết ngân hàng'),
                  ),
                  _buildSettingTile(
                    icon: Icons.verified_user_outlined,
                    title: 'Bảo mật 2 lớp',
                    subtitle: 'Bật xác minh khi đăng nhập',
                    onTap: () => _showSimpleMessage('Mở cài đặt bảo mật 2 lớp'),
                  ),
                  const SizedBox(height: 14),
                  _buildSectionTitle('Cài đặt thông báo'),
                  const SizedBox(height: 8),
                  _buildToggleTile(
                    icon: Icons.notifications_active_outlined,
                    title: 'Thông báo đẩy',
                    value: _pushEnabled,
                    onChanged: (v) => setState(() => _pushEnabled = v),
                  ),
                  _buildToggleTile(
                    icon: Icons.email_outlined,
                    title: 'Thông báo email',
                    value: _emailEnabled,
                    onChanged: (v) => setState(() => _emailEnabled = v),
                  ),
                  _buildToggleTile(
                    icon: Icons.sms_outlined,
                    title: 'Thông báo SMS',
                    value: _smsEnabled,
                    onChanged: (v) => setState(() => _smsEnabled = v),
                  ),
                  const SizedBox(height: 14),
                  _buildSectionTitle('Khác'),
                  const SizedBox(height: 8),
                  _buildSettingTile(
                    icon: Icons.help_outline,
                    title: 'Trợ giúp',
                    subtitle: 'FAQ, liên hệ hỗ trợ',
                    onTap: () => _showSimpleMessage('Mở trung tâm trợ giúp'),
                  ),
                  _buildSettingTile(
                    icon: Icons.description_outlined,
                    title: 'Điều khoản sử dụng',
                    subtitle: 'Chính sách & quyền riêng tư',
                    onTap: () => _showSimpleMessage('Mở điều khoản sử dụng'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _handleLogout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: Text(
                        'Đăng xuất',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: cardLight,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon:
                const Icon(Icons.arrow_back_ios_new, color: textDark, size: 20),
          ),
          Expanded(
            child: Text(
              'Cài đặt & Tài khoản',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(String email) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: primaryGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person, color: Color(0xFFB39129), size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tài khoản hiện tại',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textMuted,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderLight),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: primaryGold),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: textMuted,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: textMuted),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderLight),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: primaryGold,
        title: Row(
          children: [
            Icon(icon, color: primaryGold, size: 20),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSimpleMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleLogout() async {
    await _supabaseService.signOut();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
