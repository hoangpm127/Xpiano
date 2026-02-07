// Script để approve tất cả giáo viên pending
// Chạy: dart run scripts/approve_teachers.dart

import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  print('🔄 Đang kết nối Supabase...');
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL', // Thay bằng URL thực của bạn
    anonKey: 'YOUR_SUPABASE_ANON_KEY', // Thay bằng anon key thực của bạn
  );

  final supabase = Supabase.instance.client;

  try {
    print('📋 Đang lấy danh sách giáo viên pending...');
    
    // Get all pending teachers
    final pendingTeachers = await supabase
        .from('teacher_profiles')
        .select('id, full_name, verification_status')
        .eq('verification_status', 'pending');

    if (pendingTeachers.isEmpty) {
      print('✅ Không có giáo viên nào đang chờ duyệt!');
      return;
    }

    print('📝 Tìm thấy ${pendingTeachers.length} giáo viên chờ duyệt:');
    for (var teacher in pendingTeachers) {
      print('   - ${teacher['full_name']} (ID: ${teacher['id']})');
    }

    print('\n🔄 Đang approve tất cả...');

    // Update all to approved
    await supabase
        .from('teacher_profiles')
        .update({
          'verification_status': 'approved',
          'approved_at': DateTime.now().toIso8601String(),
        })
        .eq('verification_status', 'pending');

    print('✅ Đã approve ${pendingTeachers.length} giáo viên thành công!\n');

    // Verify
    final approvedTeachers = await supabase
        .from('teacher_profiles')
        .select('id, full_name, verification_status, approved_at')
        .eq('verification_status', 'approved');

    print('📊 Tổng số giáo viên đã approve: ${approvedTeachers.length}');
    
  } catch (e) {
    print('❌ Lỗi: $e');
  }
}
