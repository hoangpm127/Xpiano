# 📚 Database Sync Guide - Đồng bộ dữ liệu giữa Mobile App & Website

## 1. Dữ liệu được lưu khi đăng ký (Supabase Auth)

### 🔐 Bảng `auth.users` (Supabase Auth - Tự động tạo)

Khi user đăng ký qua mobile app, Supabase tự động lưu vào `auth.users`:

```sql
SELECT 
  id,                    -- UUID (Primary Key)
  email,                 -- Email đăng nhập
  encrypted_password,    -- Mật khẩu đã mã hóa
  email_confirmed_at,    -- Thời gian xác thực email (null nếu chưa)
  raw_user_meta_data,    -- JSON metadata từ app
  created_at,            -- Thời gian tạo tài khoản
  updated_at,            -- Thời gian cập nhật
  last_sign_in_at        -- Lần đăng nhập gần nhất
FROM auth.users
WHERE email = 'user@example.com';
```

#### JSON trong `raw_user_meta_data`:
```json
{
  "full_name": "Nguyễn Văn A",
  "role": "teacher"  // hoặc "student"
}
```

**Lưu ý quan trọng**: 
- `raw_user_meta_data` có thể access qua `user.user_metadata` trong Supabase SDK
- Email chưa được xác thực (`email_confirmed_at = null`) vì app mobile dùng OTP riêng
- Password đã được hash bởi Supabase (không thể đọc plaintext)

---

## 2. Dữ liệu giáo viên sau khi hoàn thành 3 bước setup

### 👨‍🏫 Bảng `teacher_profiles` (Custom table)

Khi giáo viên hoàn thành 3 bước setup profile, dữ liệu được lưu vào:

```sql
-- Cấu trúc bảng teacher_profiles
CREATE TABLE teacher_profiles (
  -- Định danh
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) UNIQUE,
  
  -- Step 1: Thông tin cơ bản
  full_name TEXT NOT NULL,
  specializations TEXT[] NOT NULL,        -- VD: ["Classical", "Jazz"]
  years_experience INTEGER DEFAULT 0,
  bio TEXT,
  teach_online BOOLEAN DEFAULT false,
  teach_offline BOOLEAN DEFAULT false,
  locations TEXT[] DEFAULT '{}',          -- VD: ["Quận 1", "Quận 3"]
  
  -- Step 2: Giá và gói
  price_online INTEGER,                   -- Giá 1 buổi online (VNĐ)
  price_offline INTEGER,                  -- Giá 1 buổi offline (VNĐ)
  bundle_8_sessions INTEGER DEFAULT 8,
  bundle_8_discount NUMERIC DEFAULT 10,   -- % giảm giá
  bundle_12_sessions INTEGER DEFAULT 12,
  bundle_12_discount NUMERIC DEFAULT 15,  -- % giảm giá
  allow_trial_lesson BOOLEAN DEFAULT true,
  
  -- Step 3: Xác minh & Ngân hàng
  id_number TEXT,                         -- Số CCCD/CMND
  id_front_url TEXT,                      -- URL ảnh mặt trước
  id_back_url TEXT,                       -- URL ảnh mặt sau
  bank_name TEXT,                         -- Tên ngân hàng
  bank_account TEXT,                      -- Số tài khoản
  account_holder TEXT,                    -- Tên chủ tài khoản
  certificates_description TEXT,
  certificate_urls TEXT[] DEFAULT '{}',   -- Mảng URLs ảnh chứng chỉ
  
  -- Media
  avatar_url TEXT,                        -- URL ảnh đại diện
  video_demo_url TEXT,                    -- URL video giới thiệu
  
  -- Trạng thái duyệt
  verification_status TEXT DEFAULT 'pending', -- pending/approved/rejected
  rejected_reason TEXT,
  approved_at TIMESTAMP,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

#### Ví dụ dữ liệu thực tế:
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "user_id": "987fcdeb-51a2-43c7-9f8a-d12345678901",
  "full_name": "Nguyễn Văn A",
  "specializations": ["Classical Piano", "Jazz", "Pop"],
  "years_experience": 5,
  "bio": "Giáo viên Piano chuyên nghiệp với 5 năm kinh nghiệm...",
  "teach_online": true,
  "teach_offline": true,
  "locations": ["Quận 1, TP.HCM", "Quận 3, TP.HCM"],
  
  "price_online": 250000,
  "price_offline": 350000,
  "bundle_8_sessions": 8,
  "bundle_8_discount": 10,
  "bundle_12_sessions": 12,
  "bundle_12_discount": 15,
  "allow_trial_lesson": true,
  
  "id_number": "0123456789",
  "id_front_url": "https://xxx.supabase.co/storage/v1/object/public/teacher-profiles/user_id/id_cards/front.jpg",
  "id_back_url": "https://xxx.supabase.co/storage/v1/object/public/teacher-profiles/user_id/id_cards/back.jpg",
  "bank_name": "Vietcombank",
  "bank_account": "1234567890",
  "account_holder": "NGUYEN VAN A",
  "certificates_description": "Bằng tốt nghiệp Nhạc viện...",
  "certificate_urls": [
    "https://xxx.supabase.co/storage/v1/object/public/teacher-profiles/user_id/certificates/cert1.jpg",
    "https://xxx.supabase.co/storage/v1/object/public/teacher-profiles/user_id/certificates/cert2.jpg"
  ],
  
  "avatar_url": "https://xxx.supabase.co/storage/v1/object/public/teacher-profiles/user_id/avatars/avatar.jpg",
  "video_demo_url": "https://xxx.supabase.co/storage/v1/object/public/teacher-profiles/user_id/videos/demo.mp4",
  
  "verification_status": "pending",
  "rejected_reason": null,
  "approved_at": null,
  
  "created_at": "2026-02-07T10:30:00Z",
  "updated_at": "2026-02-07T10:30:00Z"
}
```

---

## 3. Cấu trúc Storage (Supabase Storage)

### 📁 Bucket: `teacher-profiles`

```
teacher-profiles/
├── {user_id}/
│   ├── avatars/
│   │   └── 1738932000000_avatar.jpg
│   ├── videos/
│   │   └── 1738932000000_demo.mp4
│   ├── id_cards/
│   │   ├── 1738932000000_front.jpg
│   │   └── 1738932000000_back.jpg
│   └── certificates/
│       ├── 1738932000000_cert1.jpg
│       ├── 1738932000000_cert2.jpg
│       └── 1738932000000_cert3.jpg
```

**Public URLs format:**
```
https://[PROJECT_REF].supabase.co/storage/v1/object/public/teacher-profiles/{user_id}/{folder}/{filename}
```

---

## 4. API để đồng bộ với Website Backend

### 🔌 REST API Endpoints (Sử dụng Supabase REST API)

#### A. Lấy thông tin user cơ bản
```http
GET /auth/v1/user
Authorization: Bearer {access_token}

Response:
{
  "id": "uuid",
  "email": "user@example.com",
  "user_metadata": {
    "full_name": "Nguyễn Văn A",
    "role": "teacher"
  },
  "created_at": "2026-02-07T10:30:00Z"
}
```

#### B. Lấy profile giáo viên
```http
GET /rest/v1/teacher_profiles?user_id=eq.{user_id}
Authorization: Bearer {access_token}
apikey: {supabase_anon_key}

Response:
{
  "data": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "full_name": "Nguyễn Văn A",
      "specializations": ["Classical", "Jazz"],
      // ... all fields
    }
  ]
}
```

#### C. Lấy danh sách giáo viên đã duyệt (Public)
```http
GET /rest/v1/teacher_profiles?verification_status=eq.approved
apikey: {supabase_anon_key}

Response:
{
  "data": [
    {
      "id": "uuid",
      "full_name": "Nguyễn Văn A",
      "specializations": ["Classical", "Jazz"],
      "price_online": 250000,
      "avatar_url": "https://...",
      // Không trả về: id_number, bank_account (bảo mật)
    }
  ]
}
```

#### D. Duyệt/Từ chối profile (Admin only)
```http
PATCH /rest/v1/teacher_profiles?user_id=eq.{user_id}
Authorization: Bearer {admin_token}
apikey: {supabase_service_role_key}
Content-Type: application/json

Body:
{
  "verification_status": "approved",
  "approved_at": "2026-02-07T15:30:00Z"
}

// Hoặc từ chối:
{
  "verification_status": "rejected",
  "rejected_reason": "CCCD không rõ ràng"
}
```

---

## 5. Cách tích hợp vào Website (NextJS/React)

### 📝 Ví dụ code TypeScript

```typescript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

// 1. Lấy user đang đăng nhập
async function getCurrentUser() {
  const { data, error } = await supabase.auth.getUser()
  return data.user
}

// 2. Lấy profile giáo viên theo user_id
async function getTeacherProfile(userId: string) {
  const { data, error } = await supabase
    .from('teacher_profiles')
    .select('*')
    .eq('user_id', userId)
    .single()
  
  return data
}

// 3. Lấy danh sách giáo viên đã duyệt (Public)
async function getApprovedTeachers() {
  const { data, error } = await supabase
    .from('teacher_profiles')
    .select(`
      id,
      full_name,
      specializations,
      years_experience,
      bio,
      teach_online,
      teach_offline,
      locations,
      price_online,
      price_offline,
      avatar_url,
      video_demo_url,
      bundle_8_sessions,
      bundle_8_discount,
      bundle_12_sessions,
      bundle_12_discount,
      allow_trial_lesson
    `)
    .eq('verification_status', 'approved')
    .order('created_at', { ascending: false })
  
  return data
}

// 4. Tìm kiếm giáo viên theo specialization
async function searchTeachers(specialization: string) {
  const { data, error } = await supabase
    .from('teacher_profiles')
    .select('*')
    .eq('verification_status', 'approved')
    .contains('specializations', [specialization])
  
  return data
}

// 5. Admin: Duyệt profile
async function approveTeacher(userId: string, adminToken: string) {
  const { data, error } = await supabase
    .from('teacher_profiles')
    .update({
      verification_status: 'approved',
      approved_at: new Date().toISOString()
    })
    .eq('user_id', userId)
  
  return data
}
```

---

## 6. Security & RLS Policies đã cài đặt

### 🔒 Row Level Security (RLS) Policies

```sql
-- 1. User có thể xem profile của chính họ
CREATE POLICY "Users can view their own profile"
  ON teacher_profiles FOR SELECT
  USING (auth.uid() = user_id);

-- 2. User có thể tạo profile cho chính họ
CREATE POLICY "Users can insert their own profile"
  ON teacher_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 3. User có thể update profile của chính họ
CREATE POLICY "Users can update their own profile"
  ON teacher_profiles FOR UPDATE
  USING (auth.uid() = user_id);

-- 4. Ai cũng có thể xem profile đã được duyệt (public)
CREATE POLICY "Anyone can view approved profiles"
  ON teacher_profiles FOR SELECT
  USING (verification_status = 'approved');
```

### 🗂️ Storage Policies

```sql
-- 1. Ai cũng có thể xem ảnh (public bucket)
CREATE POLICY "Anyone can view profile images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'teacher-profiles');

-- 2. User đã đăng nhập có thể upload ảnh
CREATE POLICY "Authenticated users can upload profile images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'teacher-profiles' AND auth.role() = 'authenticated');

-- 3. User chỉ có thể xóa ảnh của chính họ
CREATE POLICY "Users can delete their own profile images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'teacher-profiles' AND auth.uid()::text = (storage.foldername(name))[1]);
```

---

## 7. Workflow đồng bộ giữa Mobile App & Website

### 📱 Mobile App (Flutter)
1. User đăng ký → Lưu vào `auth.users` (email, password, metadata)
2. Nếu role = 'teacher' → Setup 3 bước → Lưu vào `teacher_profiles`
3. Upload ảnh/video → Lưu vào Storage bucket `teacher-profiles`

### 💻 Website (NextJS/React)
1. **Login**: Dùng Supabase Auth (`signInWithPassword`)
2. **Dashboard**: Lấy user info từ `auth.users` + profile từ `teacher_profiles`
3. **Browse Teachers**: Query `teacher_profiles` với filter `verification_status = 'approved'`
4. **Admin Panel**: 
   - List pending profiles
   - View uploaded documents
   - Approve/Reject với button
5. **Real-time sync**: Subscribe to changes với Supabase Realtime

```typescript
// Real-time subscription
supabase
  .channel('teacher_profiles_changes')
  .on('postgres_changes', 
    { event: '*', schema: 'public', table: 'teacher_profiles' },
    (payload) => {
      console.log('Change received!', payload)
      // Update UI automatically
    }
  )
  .subscribe()
```

---

## 8. Checklist Setup cho Website

- [ ] Install `@supabase/supabase-js` trong NextJS project
- [ ] Thêm environment variables:
  ```env
  NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
  NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJxxx...
  SUPABASE_SERVICE_ROLE_KEY=eyJxxx... (cho server-side admin)
  ```
- [ ] Tạo Supabase client trong `lib/supabase.ts`
- [ ] Tạo types TypeScript cho `teacher_profiles` table
- [ ] Implement authentication flow (login/logout)
- [ ] Tạo admin dashboard để duyệt teacher profiles
- [ ] Tạo public page để browse approved teachers
- [ ] Test RLS policies (không user nào có thể thấy dữ liệu nhạy cảm)

---

## 9. SQL Queries hữu ích cho Admin Dashboard

```sql
-- Đếm số profile pending
SELECT COUNT(*) FROM teacher_profiles WHERE verification_status = 'pending';

-- Lấy teacher mới đăng ký (chưa duyệt)
SELECT 
  tp.*,
  u.email,
  u.created_at as user_created_at
FROM teacher_profiles tp
JOIN auth.users u ON tp.user_id = u.id
WHERE tp.verification_status = 'pending'
ORDER BY tp.created_at DESC;

-- Top 10 giáo viên theo kinh nghiệm
SELECT full_name, years_experience, specializations, avatar_url
FROM teacher_profiles
WHERE verification_status = 'approved'
ORDER BY years_experience DESC
LIMIT 10;

-- Thống kê theo specialization
SELECT 
  unnest(specializations) as specialization,
  COUNT(*) as teacher_count
FROM teacher_profiles
WHERE verification_status = 'approved'
GROUP BY specialization
ORDER BY teacher_count DESC;
```

---

## 10. Notes quan trọng

⚠️ **Bảo mật**:
- Không bao giờ expose `id_number`, `bank_account`, `id_front_url`, `id_back_url` ra public API
- Chỉ admin (service_role_key) mới được access các field nhạy cảm này
- Luôn dùng RLS policies để kiểm soát access

🔄 **Đồng bộ**:
- Mobile app và website đều connect vào cùng 1 Supabase project
- Dữ liệu được đồng bộ real-time tự động
- Không cần API server riêng - Supabase cung cấp REST API sẵn

📊 **Analytics**:
- Track số lượng teacher pending/approved/rejected
- Monitor upload files size (storage usage)
- Track login activity từ `auth.users.last_sign_in_at`

---

## 📩 Contact

Nếu cần thêm thông tin hoặc có vấn đề gì, vui lòng tham khảo:
- [Supabase Docs](https://supabase.com/docs)
- [Supabase Auth Guide](https://supabase.com/docs/guides/auth)
- [Supabase Storage Guide](https://supabase.com/docs/guides/storage)
