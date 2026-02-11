-- FIX RLS POLICY: Cho phép đọc teacher_profiles mà không cần login
-- Chạy script này trong Supabase SQL Editor

-- 1. Enable RLS nếu chưa có
ALTER TABLE teacher_profiles ENABLE ROW LEVEL SECURITY;

-- 2. Drop existing policies (nếu có)
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON teacher_profiles;
DROP POLICY IF EXISTS "Users can view all teacher profiles" ON teacher_profiles;
DROP POLICY IF EXISTS "Allow public read access" ON teacher_profiles;

-- 3. Tạo policy mới: Cho phép SELECT tất cả profiles (public read)
CREATE POLICY "Allow public read access to teacher profiles"
ON teacher_profiles
FOR SELECT
TO public
USING (true);

-- 4. Tạo policy: User chỉ có thể update/delete profile của chính mình
CREATE POLICY "Users can update own teacher profile"
ON teacher_profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can insert own teacher profile"
ON teacher_profiles
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- 5. Kiểm tra policies
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'teacher_profiles';

-- 6. Test query
SELECT count(*) as total_teachers FROM teacher_profiles;
SELECT full_name, verification_status FROM teacher_profiles ORDER BY created_at DESC;
