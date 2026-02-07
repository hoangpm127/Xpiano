-- ============================================
-- SQL QUERIES FOR TESTING & MANAGEMENT
-- Chạy trên Supabase Dashboard > SQL Editor
-- ============================================

-- ============================================
-- 1. KIỂM TRA DỮ LIỆU SAU KHI ĐĂNG KÝ
-- ============================================

-- Xem tất cả users đã đăng ký
SELECT 
  id,
  email,
  raw_user_meta_data->>'full_name' as full_name,
  raw_user_meta_data->>'role' as role,
  email_confirmed_at,
  created_at,
  last_sign_in_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 20;

-- Xem user cụ thể theo email
SELECT 
  id,
  email,
  raw_user_meta_data->>'full_name' as full_name,
  raw_user_meta_data->>'role' as role,
  created_at
FROM auth.users
WHERE email = 'teacher@example.com';

-- Đếm số users theo role
SELECT 
  raw_user_meta_data->>'role' as role,
  COUNT(*) as total
FROM auth.users
GROUP BY raw_user_meta_data->>'role';

-- ============================================
-- 2. KIỂM TRA TEACHER PROFILES
-- ============================================

-- Xem tất cả teacher profiles
SELECT 
  tp.id,
  tp.full_name,
  tp.specializations,
  tp.years_experience,
  tp.verification_status,
  u.email,
  tp.created_at
FROM teacher_profiles tp
JOIN auth.users u ON tp.user_id = u.id
ORDER BY tp.created_at DESC;

-- Xem chi tiết 1 teacher profile (full data)
SELECT 
  tp.*,
  u.email,
  u.raw_user_meta_data->>'role' as user_role
FROM teacher_profiles tp
JOIN auth.users u ON tp.user_id = u.id
WHERE u.email = 'teacher@example.com';

-- Xem teacher profile theo user_id
SELECT * FROM teacher_profiles
WHERE user_id = 'YOUR_USER_UUID_HERE';

-- ============================================
-- 3. THỐNG KÊ & DASHBOARD
-- ============================================

-- Thống kê tổng quan
SELECT 
  COUNT(*) FILTER (WHERE verification_status = 'pending') as pending,
  COUNT(*) FILTER (WHERE verification_status = 'approved') as approved,
  COUNT(*) FILTER (WHERE verification_status = 'rejected') as rejected,
  COUNT(*) as total
FROM teacher_profiles;

-- Top 10 giáo viên theo kinh nghiệm
SELECT 
  full_name,
  years_experience,
  specializations,
  price_online,
  price_offline,
  avatar_url
FROM teacher_profiles
WHERE verification_status = 'approved'
ORDER BY years_experience DESC
LIMIT 10;

-- Top 10 giáo viên mới nhất
SELECT 
  full_name,
  specializations,
  verification_status,
  created_at
FROM teacher_profiles
ORDER BY created_at DESC
LIMIT 10;

-- Thống kê theo specialization
SELECT 
  unnest(specializations) as specialization,
  COUNT(*) as teacher_count
FROM teacher_profiles
WHERE verification_status = 'approved'
GROUP BY specialization
ORDER BY teacher_count DESC;

-- Thống kê theo location
SELECT 
  unnest(locations) as location,
  COUNT(*) as teacher_count
FROM teacher_profiles
WHERE verification_status = 'approved'
GROUP BY location
ORDER BY teacher_count DESC
LIMIT 20;

-- Giá trung bình online/offline
SELECT 
  AVG(price_online) as avg_online,
  AVG(price_offline) as avg_offline,
  MIN(price_online) as min_online,
  MAX(price_online) as max_online,
  MIN(price_offline) as min_offline,
  MAX(price_offline) as max_offline
FROM teacher_profiles
WHERE verification_status = 'approved';

-- ============================================
-- 4. TÌM KIẾM & LỌC
-- ============================================

-- Tìm teacher theo specialization
SELECT 
  full_name,
  specializations,
  years_experience,
  price_online,
  avatar_url
FROM teacher_profiles
WHERE verification_status = 'approved'
  AND specializations @> ARRAY['Classical Piano']
ORDER BY years_experience DESC;

-- Tìm teacher dạy online trong khoảng giá
SELECT 
  full_name,
  specializations,
  price_online,
  locations,
  avatar_url
FROM teacher_profiles
WHERE verification_status = 'approved'
  AND teach_online = true
  AND price_online BETWEEN 200000 AND 300000
ORDER BY price_online ASC;

-- Tìm teacher ở địa điểm cụ thể
SELECT 
  full_name,
  specializations,
  locations,
  price_offline,
  teach_offline
FROM teacher_profiles
WHERE verification_status = 'approved'
  AND teach_offline = true
  AND locations @> ARRAY['Quận 1, TP.HCM']
ORDER BY years_experience DESC;

-- Tìm teacher có trial lesson
SELECT 
  full_name,
  specializations,
  price_online,
  price_offline,
  allow_trial_lesson
FROM teacher_profiles
WHERE verification_status = 'approved'
  AND allow_trial_lesson = true
ORDER BY created_at DESC;

-- ============================================
-- 5. ADMIN OPERATIONS
-- ============================================

-- Xem tất cả profiles chờ duyệt (với thông tin nhạy cảm)
SELECT 
  tp.id,
  tp.full_name,
  u.email,
  tp.id_number,
  tp.bank_name,
  tp.bank_account,
  tp.account_holder,
  tp.id_front_url,
  tp.id_back_url,
  tp.certificate_urls,
  tp.created_at
FROM teacher_profiles tp
JOIN auth.users u ON tp.user_id = u.id
WHERE tp.verification_status = 'pending'
ORDER BY tp.created_at ASC;

-- Duyệt 1 profile (Approve)
UPDATE teacher_profiles
SET 
  verification_status = 'approved',
  approved_at = NOW(),
  rejected_reason = NULL
WHERE user_id = 'YOUR_USER_UUID_HERE';

-- Từ chối 1 profile (Reject)
UPDATE teacher_profiles
SET 
  verification_status = 'rejected',
  rejected_reason = 'CCCD không rõ ràng, vui lòng upload lại',
  approved_at = NULL
WHERE user_id = 'YOUR_USER_UUID_HERE';

-- Reset về pending (để xem lại)
UPDATE teacher_profiles
SET 
  verification_status = 'pending',
  rejected_reason = NULL,
  approved_at = NULL
WHERE user_id = 'YOUR_USER_UUID_HERE';

-- Xóa profile (cẩn thận!)
DELETE FROM teacher_profiles
WHERE user_id = 'YOUR_USER_UUID_HERE';

-- ============================================
-- 6. XEM STORAGE FILES
-- ============================================

-- Lấy danh sách files trong storage (chạy bằng RPC hoặc SDK)
-- Không thể query trực tiếp storage.objects từ SQL Editor
-- Phải dùng Supabase Dashboard > Storage > teacher-profiles

-- Nhưng có thể xem metadata từ teacher_profiles
SELECT 
  full_name,
  avatar_url,
  video_demo_url,
  id_front_url,
  id_back_url,
  certificate_urls
FROM teacher_profiles
WHERE user_id = 'YOUR_USER_UUID_HERE';

-- ============================================
-- 7. BẢO TRÌ & CLEAN UP
-- ============================================

-- Tìm profiles không có avatar
SELECT 
  full_name,
  email,
  created_at
FROM teacher_profiles tp
JOIN auth.users u ON tp.user_id = u.id
WHERE avatar_url IS NULL
ORDER BY created_at DESC;

-- Tìm profiles không có video demo
SELECT 
  full_name,
  created_at
FROM teacher_profiles
WHERE video_demo_url IS NULL
ORDER BY created_at DESC;

-- Tìm profiles bị reject
SELECT 
  tp.full_name,
  u.email,
  tp.rejected_reason,
  tp.updated_at
FROM teacher_profiles tp
JOIN auth.users u ON tp.user_id = u.id
WHERE verification_status = 'rejected'
ORDER BY tp.updated_at DESC;

-- Xóa profiles bị reject lâu hơn 30 ngày
DELETE FROM teacher_profiles
WHERE verification_status = 'rejected'
  AND updated_at < NOW() - INTERVAL '30 days';

-- ============================================
-- 8. ANALYTICS & REPORTING
-- ============================================

-- Số lượng đăng ký mới theo ngày (7 ngày qua)
SELECT 
  DATE(created_at) as date,
  COUNT(*) as new_registrations
FROM teacher_profiles
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- Số lượng approved profiles theo tháng
SELECT 
  DATE_TRUNC('month', approved_at) as month,
  COUNT(*) as approved_count
FROM teacher_profiles
WHERE verification_status = 'approved'
  AND approved_at IS NOT NULL
GROUP BY DATE_TRUNC('month', approved_at)
ORDER BY month DESC;

-- Teacher growth over time
SELECT 
  DATE_TRUNC('week', created_at) as week,
  COUNT(*) as total_registrations,
  COUNT(*) FILTER (WHERE verification_status = 'approved') as approved,
  COUNT(*) FILTER (WHERE verification_status = 'pending') as pending,
  COUNT(*) FILTER (WHERE verification_status = 'rejected') as rejected
FROM teacher_profiles
WHERE created_at >= NOW() - INTERVAL '3 months'
GROUP BY DATE_TRUNC('week', created_at)
ORDER BY week DESC;

-- ============================================
-- 9. TESTING & DEBUGGING
-- ============================================

-- Kiểm tra RLS policies (chạy như authenticated user)
SET request.jwt.claims = '{"sub": "YOUR_USER_UUID_HERE"}';

-- Test xem user có thể xem profile của chính họ không
SELECT * FROM teacher_profiles WHERE user_id = 'YOUR_USER_UUID_HERE';

-- Test xem user có thể xem profiles đã approved không
SELECT * FROM teacher_profiles WHERE verification_status = 'approved';

-- Reset session
RESET ALL;

-- Kiểm tra indexes
SELECT 
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename = 'teacher_profiles';

-- Kiểm tra table size & storage usage
SELECT 
  pg_size_pretty(pg_total_relation_size('teacher_profiles')) as total_size,
  pg_size_pretty(pg_relation_size('teacher_profiles')) as table_size,
  pg_size_pretty(pg_indexes_size('teacher_profiles')) as indexes_size;

-- ============================================
-- 10. SAMPLE DATA INSERT (FOR TESTING)
-- ============================================

-- Insert sample teacher profile (thay YOUR_USER_UUID bằng UUID thực)
INSERT INTO teacher_profiles (
  user_id,
  full_name,
  specializations,
  years_experience,
  bio,
  teach_online,
  teach_offline,
  locations,
  price_online,
  price_offline,
  bundle_8_sessions,
  bundle_8_discount,
  bundle_12_sessions,
  bundle_12_discount,
  allow_trial_lesson,
  verification_status
) VALUES (
  'YOUR_USER_UUID_HERE',
  'Nguyễn Văn A',
  ARRAY['Classical Piano', 'Jazz'],
  5,
  'Giáo viên Piano chuyên nghiệp với 5 năm kinh nghiệm.',
  true,
  true,
  ARRAY['Quận 1, TP.HCM', 'Quận 3, TP.HCM'],
  250000,
  350000,
  8,
  10,
  12,
  15,
  true,
  'pending'
);

-- ============================================
-- 11. BACKUP & EXPORT
-- ============================================

-- Export all teacher profiles to CSV format
COPY (
  SELECT 
    tp.full_name,
    u.email,
    tp.specializations,
    tp.years_experience,
    tp.verification_status,
    tp.price_online,
    tp.price_offline,
    tp.created_at
  FROM teacher_profiles tp
  JOIN auth.users u ON tp.user_id = u.id
) TO '/tmp/teacher_profiles.csv' WITH CSV HEADER;

-- Note: COPY TO chỉ chạy trên database server, không chạy được trên Dashboard
-- Dùng Supabase API hoặc pg_dump thay thế

-- ============================================
-- 12. PERFORMANCE OPTIMIZATION
-- ============================================

-- Analyze table statistics
ANALYZE teacher_profiles;

-- Vacuum table (clean up dead rows)
VACUUM ANALYZE teacher_profiles;

-- Check slow queries
SELECT 
  query,
  calls,
  total_time,
  mean_time,
  max_time
FROM pg_stat_statements
WHERE query ILIKE '%teacher_profiles%'
ORDER BY mean_time DESC
LIMIT 10;

-- ============================================
-- END OF QUERIES
-- ============================================
