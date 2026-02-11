-- ============================================
-- XPiano Social Feed - Sample Data
-- ============================================
-- Run this in your Supabase SQL Editor to populate test data

-- Clean existing data (optional)
-- TRUNCATE social_feed, pianos CASCADE;

-- ============================================
-- SOCIAL FEED POSTS
-- ============================================

-- Post 1: Piano Technique Tutorial
INSERT INTO social_feed (
  author_name, 
  author_avatar, 
  caption, 
  media_url, 
  likes_count, 
  comments_count, 
  shares_count, 
  hashtags, 
  is_verified, 
  location, 
  music_credit
) VALUES (
  'LinhPiano',
  'https://i.pravatar.cc/150?img=1',
  '30 giây luyện ngón giúp tay mềm hơn 🎹 Kỹ thuật này giúp cải thiện độ linh hoạt đáng kể!',
  'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=1080&q=80',
  1234,
  345,
  89,
  ARRAY['luyenngon', 'piano', 'xpiano', 'beginner', 'technique'],
  true,
  'Hà Nội',
  'Âm thanh gốc • @AnNhien'
);

-- Post 2: Piano Performance
INSERT INTO social_feed (
  author_name, 
  author_avatar, 
  caption, 
  media_url, 
  likes_count, 
  comments_count, 
  shares_count,
  hashtags, 
  is_verified,
  location,
  music_credit
) VALUES (
  'PianoMaster',
  'https://i.pravatar.cc/150?img=5',
  'Học piano cùng chuyên gia 15 năm kinh nghiệm 🎼 Đăng ký ngay để nhận ưu đãi!',
  'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=1080&q=80',
  5678,
  892,
  234,
  ARRAY['hocpiano', 'chuyengia', 'xpiano', 'masterclass'],
  true,
  'TP. Hồ Chí Minh',
  'Original Sound • Chopin'
);

-- Post 3: Piano Rental Showcase
INSERT INTO social_feed (
  author_name, 
  author_avatar, 
  caption, 
  media_url, 
  likes_count, 
  comments_count, 
  shares_count,
  hashtags, 
  is_verified,
  location
) VALUES (
  'XPiano Official',
  'https://i.pravatar.cc/150?img=8',
  'Đàn Yamaha U3 vừa về kho! 🔥 Trải nghiệm ngay tại showroom. #ThueĐànGiảGiá',
  'https://images.unsplash.com/photo-1552422535-c45813c61732?w=1080&q=80',
  3456,
  521,
  178,
  ARRAY['yamaha', 'rentalpiano', 'xpiano', 'showroom'],
  true,
  'Đà Nẵng'
);

-- Post 4: Student performance
INSERT INTO social_feed (
  author_name, 
  author_avatar, 
  caption, 
  media_url, 
  likes_count, 
  comments_count, 
  shares_count,
  hashtags, 
  is_verified,
  music_credit
) VALUES (
  'MinhNguyen',
  'https://i.pravatar.cc/150?img=12',
  'Sau 3 tháng học tại XPiano 🎹 Cảm ơn thầy đã dạy rất tận tâm!',
  'https://images.unsplash.com/photo-1612225330812-01a9c6b355ec?w=1080&q=80',
  987,
  156,
  45,
  ARRAY['progress', 'student', 'xpiano', 'grateful'],
  false,
  'Moonlight Sonata - Beethoven'
);

-- Post 5: Piano maintenance tips
INSERT INTO social_feed (
  author_name, 
  author_avatar, 
  caption, 
  media_url, 
  likes_count, 
  comments_count, 
  shares_count,
  hashtags, 
  is_verified,
  location,
  music_credit
) VALUES (
  'PianoCarePro',
  'https://i.pravatar.cc/150?img=15',
  'Bảo dưỡng đàn piano đúng cách giúp giữ âm thanh tốt nhất! Xem video để biết thêm chi tiết 👇',
  'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=1080&q=80',
  2345,
  423,
  112,
  ARRAY['maintenance', 'pianocare', 'tips', 'xpiano'],
  true,
  'Hà Nội',
  'Background Music • @PianoCarePro'
);

-- ============================================
-- PIANO RENTALS
-- ============================================

-- Piano 1: Yamaha U3
INSERT INTO pianos (
  name, 
  image_url, 
  category, 
  price_per_hour, 
  rating, 
  description, 
  brand,
  is_available
) VALUES (
  'Yamaha U3',
  'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=600&q=80',
  'Upright Piano',
  50,
  4.8,
  'Đàn piano cơ Yamaha U3 chất lượng cao, âm thanh ấm áp, phù hợp cho người mới học và trình độ trung cấp.',
  'Yamaha',
  true
);

-- Piano 2: Kawai K3
INSERT INTO pianos (
  name, 
  image_url, 
  category, 
  price_per_hour, 
  rating, 
  description, 
  brand,
  is_available
) VALUES (
  'Kawai K3',
  'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=600&q=80',
  'Upright Piano',
  55,
  4.9,
  'Đàn Kawai K3 với chất lượng vượt trội, âm thanh trong trẻo, phím bấm êm ái.',
  'Kawai',
  true
);

-- Piano 3: Yamaha C3 Grand Piano
INSERT INTO pianos (
  name, 
  image_url, 
  category, 
  price_per_hour, 
  rating, 
  description, 
  brand,
  is_available
) VALUES (
  'Yamaha C3 Grand Piano',
  'https://images.unsplash.com/photo-1552422535-c45813c61732?w=600&q=80',
  'Grand Piano',
  120,
  5.0,
  'Grand Piano Yamaha C3 dành cho biểu diễn chuyên nghiệp, âm thanh đỉnh cao.',
  'Yamaha',
  true
);

-- Piano 4: Roland FP-30X Digital Piano
INSERT INTO pianos (
  name, 
  image_url, 
  category, 
  price_per_hour, 
  rating, 
  description, 
  brand,
  is_available
) VALUES (
  'Roland FP-30X',
  'https://images.unsplash.com/photo-1612225330812-01a9c6b355ec?w=600&q=80',
  'Digital Piano',
  35,
  4.5,
  'Đàn điện Roland FP-30X di động, phù hợp cho người mới học và luyện tập tại nhà.',
  'Roland',
  true
);

-- Piano 5: Steinway & Sons Model D
INSERT INTO pianos (
  name, 
  image_url, 
  category, 
  price_per_hour, 
  rating, 
  description, 
  brand,
  is_available
) VALUES (
  'Steinway & Sons Model D',
  'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
  'Grand Piano',
  250,
  5.0,
  'Grand Piano Steinway & Sons Model D - Đỉnh cao của nghệ thuật piano. Dành cho nghệ sĩ chuyên nghiệp.',
  'Steinway & Sons',
  false
);

-- ============================================
-- VERIFY DATA
-- ============================================

-- Count posts
SELECT COUNT(*) as total_posts FROM social_feed;

-- Count pianos
SELECT COUNT(*) as total_pianos FROM pianos;

-- Show latest posts
SELECT 
  id, 
  author_name, 
  caption, 
  likes_count, 
  created_at 
FROM social_feed 
ORDER BY created_at DESC 
LIMIT 5;

-- Show available pianos
SELECT 
  name, 
  category, 
  price_per_hour, 
  rating 
FROM pianos 
WHERE is_available = true 
ORDER BY rating DESC;
