# Hướng dẫn Setup Teacher Profiles trên Supabase

## 📋 Bước 1: Tạo Table & Storage Bucket

### 1.1. Vào Supabase Dashboard
- Mở: https://supabase.com/dashboard
- Chọn project **Xpiano**

### 1.2. Chạy SQL Script
1. Click **SQL Editor** (menu bên trái)
2. Click **"+ New Query"**
3. Copy toàn bộ nội dung file `supabase_teacher_profiles_setup.sql`
4. Paste vào SQL Editor
5. Click **"Run"** (hoặc Ctrl+Enter)
6. ✅ Xong! Table và storage bucket đã được tạo

---

## 🗂️ Table Structure: `teacher_profiles`

### **Columns:**

#### **Basic Info (Step 1):**
- `full_name` TEXT (NOT NULL)
- `specializations` TEXT[] (NOT NULL) - Array các chuyên môn
- `years_experience` INTEGER (DEFAULT 0)
- `bio` TEXT
- `teach_online` BOOLEAN (DEFAULT false)
- `teach_offline` BOOLEAN (DEFAULT false)
- `locations` TEXT[] - Array các khu vực dạy

#### **Pricing (Step 2):**
- `price_online` INTEGER
- `price_offline` INTEGER
- `bundle_8_sessions` INTEGER (DEFAULT 8)
- `bundle_8_discount` NUMERIC (DEFAULT 10)
- `bundle_12_sessions` INTEGER (DEFAULT 12)
- `bundle_12_discount` NUMERIC (DEFAULT 15)
- `allow_trial_lesson` BOOLEAN (DEFAULT true)

#### **Verification (Step 3):**
- `id_number` TEXT - Số CCCD/CMND
- `id_front_url` TEXT - URL ảnh mặt trước
- `id_back_url` TEXT - URL ảnh mặt sau
- `bank_name` TEXT
- `bank_account` TEXT
- `account_holder` TEXT
- `certificates_description` TEXT
- `certificate_urls` TEXT[] - Array URLs ảnh chứng chỉ

#### **Media:**
- `avatar_url` TEXT
- `video_demo_url` TEXT

#### **Status:**
- `verification_status` TEXT (DEFAULT 'pending')
  - `'pending'` - Chờ duyệt
  - `'approved'` - Đã duyệt
  - `'rejected'` - Bị từ chối
- `rejected_reason` TEXT
- `approved_at` TIMESTAMP

#### **Meta:**
- `user_id` UUID (REFERENCES auth.users) - UNIQUE
- `created_at` TIMESTAMP (DEFAULT NOW())
- `updated_at` TIMESTAMP (AUTO-UPDATE)

---

## 🔐 Row Level Security (RLS) Policies

### **SELECT (Read):**
- ✅ Users có thể xem profile của chính họ
- ✅ Anyone có thể xem profiles đã được approve (`verification_status = 'approved'`)

### **INSERT (Create):**
- ✅ Users chỉ có thể tạo profile cho chính họ

### **UPDATE (Modify):**
- ✅ Users chỉ có thể update profile của chính họ

### **DELETE:**
- ❌ Không cho phép (CASCADE delete khi xóa user)

---

## 📦 Storage Bucket: `teacher-profiles`

### **Structure:**
```
teacher-profiles/
  ├── {user_id}/
  │   ├── avatars/
  │   │   └── avatar_1234567890.jpg
  │   ├── videos/
  │   │   └── video_1234567890.mp4
  │   ├── id_cards/
  │   │   ├── id_front_1234567890.jpg
  │   │   └── id_back_1234567890.jpg
  │   └── certificates/
  │       ├── cert_0_1234567890.jpg
  │       ├── cert_1_1234567890.jpg
  │       └── cert_2_1234567890.jpg
```

### **Storage Policies:**
- ✅ Anyone có thể view public images
- ✅ Authenticated users có thể upload
- ✅ Users chỉ có thể update/delete images của họ

---

## 🧪 Test SQL Queries

### **1. Xem tất cả teacher profiles chờ duyệt:**
```sql
SELECT 
  id,
  full_name,
  specializations,
  verification_status,
  created_at
FROM teacher_profiles
WHERE verification_status = 'pending'
ORDER BY created_at DESC;
```

### **2. Approve một profile:**
```sql
UPDATE teacher_profiles
SET 
  verification_status = 'approved',
  approved_at = NOW()
WHERE id = 'profile-uuid-here';
```

### **3. Reject một profile:**
```sql
UPDATE teacher_profiles
SET 
  verification_status = 'rejected',
  rejected_reason = 'Lý do từ chối...'
WHERE id = 'profile-uuid-here';
```

### **4. Xem tất cả giáo viên đã approved:**
```sql
SELECT 
  full_name,
  specializations,
  bio,
  teach_online,
  teach_offline,
  price_online,
  price_offline,
  avatar_url
FROM teacher_profiles
WHERE verification_status = 'approved'
ORDER BY created_at DESC;
```

### **5. Tìm giáo viên theo chuyên môn:**
```sql
SELECT 
  full_name,
  specializations,
  locations,
  price_online
FROM teacher_profiles
WHERE 
  verification_status = 'approved'
  AND 'Piano' = ANY(specializations)
ORDER BY years_experience DESC;
```

---

## 📝 Notes

- **Auto-update timestamp:** `updated_at` tự động update mỗi khi có thay đổi
- **Unique constraint:** Mỗi user chỉ có thể có 1 teacher profile
- **Cascade delete:** Khi xóa user trong `auth.users`, profile sẽ tự động bị xóa
- **Public storage:** Tất cả images trong bucket là public (để hiển thị trên app)

---

## ✅ Verification Checklist

Sau khi chạy SQL script, check những điều sau:

- [ ] Table `teacher_profiles` đã được tạo
- [ ] Storage bucket `teacher-profiles` đã được tạo
- [ ] RLS policies đã active (check trong Table Editor → RLS tab)
- [ ] Storage policies đã active (check trong Storage → Policies)
- [ ] Test upload 1 ảnh vào bucket (manual test qua Dashboard)

---

🎉 **Done!** Bây giờ app có thể lưu teacher profiles vào Supabase rồi!
