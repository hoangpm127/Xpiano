# 🎹 XPiano - Supabase Integration Quick Start

## 🚀 Bắt Đầu Nhanh

### Bước 1: Tạo Tables trong Supabase

Vào Supabase SQL Editor và chạy:

```sql
-- Table: social_feed
CREATE TABLE social_feed (
  id BIGSERIAL PRIMARY KEY,
  author_name TEXT NOT NULL,
  author_avatar TEXT,
  caption TEXT,
  media_url TEXT NOT NULL,
  likes_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  shares_count INTEGER DEFAULT 0,
  hashtags TEXT[] DEFAULT '{}',
  is_verified BOOLEAN DEFAULT false,
  location TEXT,
  music_credit TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: pianos
CREATE TABLE pianos (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  image_url TEXT,
  category TEXT,
  price_per_hour NUMERIC,
  rating NUMERIC DEFAULT 0,
  description TEXT,
  brand TEXT,
  is_available BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Bước 2: Thêm Dữ Liệu Mẫu

Copy và paste toàn bộ file `sample_data.sql` vào Supabase SQL Editor, sau đó chạy.

### Bước 3: Chạy App

```bash
cd d:\Xpiano\mobile
flutter run -d R5CX52Q5HTA
```

## 📱 Kết Quả Mong Đợi

✅ App mở ra → Loading spinner (vàng)  
✅ Dữ liệu load từ Supabase  
✅ Hiển thị feed TikTok-style với:
- Ảnh nền từ `media_url`
- Tên tác giả + avatar
- Caption + hashtags
- Số likes, comments, shares
- Location + music credit

✅ Vuốt lên/xuống → Chuyển bài viết

## 📂 Files Quan Trọng

| File | Mô Tả |
|------|-------|
| `lib/main.dart` | Code chính - UI + Supabase integration |
| `lib/models/feed_item.dart` | Model cho social feed |
| `lib/models/piano.dart` | Model cho piano rentals |
| `lib/services/supabase_service.dart` | API calls đến Supabase |
| `sample_data.sql` | Dữ liệu mẫu (5 posts + 5 pianos) |
| `SUPABASE_INTEGRATION.md` | Tài liệu chi tiết |

## 🔧 Troubleshooting

### Lỗi: "Chưa có bài viết nào"
→ Chưa có dữ liệu trong table `social_feed`  
→ Chạy `sample_data.sql` trong Supabase

### Lỗi: "Lỗi kết nối Supabase"
→ Kiểm tra internet  
→ Kiểm tra Supabase URL và Anon Key trong `main.dart`  
→ Verify tables đã được tạo trong Supabase

### App chạy nhưng loading mãi
→ Check Supabase Dashboard xem có lỗi gì không  
→ Verify RLS (Row Level Security) policies cho phép public read

## 📖 Xem Thêm

Đọc file `SUPABASE_INTEGRATION.md` để biết:
- Chi tiết implementation
- API usage examples
- Testing methods
- Advanced features (real-time, pagination, etc.)
