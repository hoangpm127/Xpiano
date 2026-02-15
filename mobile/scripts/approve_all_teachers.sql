-- Script để approve tất cả giáo viên đang pending
-- Chạy script này trong Supabase SQL Editor

UPDATE teacher_profiles
SET 
  verification_status = 'approved',
  approved_at = NOW()
WHERE verification_status = 'pending';

-- Kiểm tra kết quả
SELECT 
  id,
  full_name,
  verification_status,
  approved_at,
  created_at
FROM teacher_profiles
ORDER BY created_at DESC;
