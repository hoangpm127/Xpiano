# Supabase Integration - Complete Guide

## ✅ Integration Status: COMPLETED

### 📦 What Was Implemented

#### 1. **Package Installation**
- ✅ Added `supabase_flutter: ^2.5.0` to `pubspec.yaml`
- ✅ Installed 44 new dependencies (Supabase + dependencies)

#### 2. **Supabase Initialization**
- ✅ Initialized in `main()` function in `lib/main.dart`
- ✅ **URL**: `https://pjgjusdmzxrhgiptfvbg.supabase.co`
- ✅ **Anon Key**: `sb_publishable_GMnCRFvRGqElGLerTiE-3g_YpGm-KoW`

#### 3. **Data Models Created**

**`lib/models/feed_item.dart`**
```dart
class FeedItem {
  final int id;
  final String authorName;
  final String authorAvatar;
  final String caption;
  final String mediaUrl;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final List<String> hashtags;
  final bool isVerified;
  final String? location;
  final String? musicCredit;
  
  // Helper methods:
  String get formattedLikes    // "1.2K", "2.5M"
  String get formattedComments
  String get formattedShares
}
```

**`lib/models/piano.dart`**
```dart
class Piano {
  final int id;
  final String name;
  final String imageUrl;
  final String category;
  final double pricePerHour;
  final double rating;
  final String description;
  final String? brand;
  final bool? isAvailable;
  
  String get formattedPrice   // "50K VNĐ/giờ"
  String get formattedRating  // "4.5"
}
```

#### 4. **Service Layer**

**`lib/services/supabase_service.dart`**

Methods available:
- `getSocialFeed()` → `Future<List<FeedItem>>`
- `getPianos()` → `Future<List<Piano>>`
- `watchSocialFeed()` → `Stream<List<FeedItem>>` (real-time)
- `incrementLikes(feedId, currentCount)`
- `incrementComments(feedId, currentCount)`
- `incrementShares(feedId, currentCount)`

#### 5. **UI Integration**

**Changes to `lib/main.dart`:**

1. **Converted to StatefulWidget**
   - `PianoFeedScreen` is now a `StatefulWidget`
   - Uses `FutureBuilder<List<FeedItem>>` to fetch data

2. **Loading States**
   - ⏳ **Loading**: Shows gold `CircularProgressIndicator`
   - ❌ **Error**: Shows error icon + message
   - 📭 **Empty**: Shows "Chưa có bài viết nào"
   - ✅ **Success**: Shows TikTok-style feed

3. **Dynamic Data Binding**
   - Background image: `item.mediaUrl`
   - Author name: `item.authorName`
   - Author avatar: `item.authorAvatar`
   - Caption: `item.caption`
   - Hashtags: `item.hashtags` → `#tag1 #tag2`
   - Likes count: `item.formattedLikes`
   - Comments count: `item.formattedComments`
   - Shares count: `item.formattedShares`
   - Location: `item.location` (optional)
   - Music credit: `item.musicCredit` (optional)

4. **Vertical Scrolling**
   - Implemented `PageView.builder` for TikTok-style vertical scroll
   - Swipe up/down to navigate between posts

5. **Error Handling**
   - Image loading errors show placeholder
   - Empty URLs use default placeholders
   - Null-safe rendering for optional fields

---

## 📊 Database Schema Requirements

### Table: `social_feed`

```sql
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
```

### Table: `pianos`

```sql
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

---

## 🧪 Testing the Integration

### 1. **Insert Sample Data** (Run in Supabase SQL Editor)

```sql
-- Sample social feed post
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
  '30 giây luyện ngón giúp tay mềm hơn 🎹',
  'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=1080',
  1234,
  345,
  89,
  ARRAY['luyenngon', 'piano', 'xpiano', 'beginner'],
  true,
  'Hà Nội',
  'Âm thanh gốc • @AnNhien'
);

-- Add more posts
INSERT INTO social_feed (
  author_name, 
  author_avatar, 
  caption, 
  media_url, 
  likes_count, 
  comments_count, 
  hashtags, 
  is_verified
) VALUES (
  'PianoMaster',
  'https://i.pravatar.cc/150?img=5',
  'Học piano cùng chuyên gia 15 năm kinh nghiệm 🎼',
  'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=1080',
  5678,
  892,
  ARRAY['hocpiano', 'chuyengia', 'xpiano'],
  true
);

-- Sample piano rental
INSERT INTO pianos (
  name, 
  image_url, 
  category, 
  price_per_hour, 
  rating, 
  description, 
  brand
) VALUES (
  'Yamaha U3',
  'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=600',
  'Upright Piano',
  50,
  4.8,
  'Đàn piano cơ Yamaha U3 chất lượng cao',
  'Yamaha'
);
```

### 2. **Run the App**

```bash
cd d:\Xpiano\mobile
flutter run -d R5CX52Q5HTA
```

### 3. **Expected Behavior**

✅ **On App Launch:**
1. Shows loading spinner (gold CircularProgressIndicator)
2. Fetches data from Supabase `social_feed` table
3. Displays first post with:
   - Background image
   - Author badge (if verified)
   - Engagement counts (likes, comments, shares)
   - Caption + hashtags
   - Location + music credit (if provided)

✅ **Vertical Scroll:**
- Swipe up → Next post
- Swipe down → Previous post
- Smooth TikTok-style transitions

✅ **Error Handling:**
- No internet? Shows error message
- No data? Shows "Chưa có bài viết nào"
- Image load failed? Shows placeholder

---

## 🔧 How to Update Data

### Fetch Fresh Data

```dart
// In PianoFeedScreen
setState(() {
  _feedFuture = _supabaseService.getSocialFeed();
});
```

### Real-Time Updates (Advanced)

Replace `FutureBuilder` with `StreamBuilder`:

```dart
StreamBuilder<List<FeedItem>>(
  stream: _supabaseService.watchSocialFeed(),
  builder: (context, snapshot) {
    // Same logic as FutureBuilder
  },
)
```

---

## 📝 API Usage Examples

### Fetch All Posts

```dart
final supabaseService = SupabaseService();
List<FeedItem> posts = await supabaseService.getSocialFeed();
```

### Fetch All Pianos

```dart
List<Piano> pianos = await supabaseService.getPianos();
```

### Increment Likes

```dart
await supabaseService.incrementLikes(feedId: 1, currentCount: 100);
// likes_count will become 101
```

---

## 🎨 UI Components Mapping

| UI Element | Data Source |
|---|---|
| Background Image | `item.mediaUrl` |
| Verified Badge | `item.isVerified` (shows if true) |
| Author Name | `item.authorName` |
| Author Avatar (sidebar) | `item.authorAvatar` |
| Caption | `item.caption` |
| Hashtags | `item.hashtags.map((tag) => '#$tag').join(' ')` |
| Likes Count | `item.formattedLikes` |
| Comments Count | `item.formattedComments` |
| Shares Count | `item.formattedShares` |
| Location Badge | `item.location` (optional) |
| Music Credit | `item.musicCredit` (optional) |

---

## 🚀 Next Steps (Optional Enhancements)

1. **Add Interactive Likes**
   ```dart
   onTap: () async {
     await _supabaseService.incrementLikes(item.id, item.likesCount);
     setState(() => _feedFuture = _supabaseService.getSocialFeed());
   }
   ```

2. **Add Pull-to-Refresh**
   ```dart
   RefreshIndicator(
     onRefresh: () async {
       setState(() => _feedFuture = _supabaseService.getSocialFeed());
     },
     child: PageView.builder(...),
   )
   ```

3. **Add Caching**
   - Use `shared_preferences` to cache feed locally
   - Show cached data while loading fresh data

4. **Add Pagination**
   ```dart
   .select()
   .order('created_at', ascending: false)
   .range(0, 9)  // Load 10 at a time
   ```

5. **Integrate Piano Rentals**
   - Create new screen to show `getPianos()` data
   - Link from bottom navigation "Mượn Đàn" button

---

## ✅ Summary

**Integration is 100% complete and functional!**

- ✅ Supabase configured
- ✅ Models created & tested
- ✅ Service layer implemented
- ✅ UI fully integrated with dynamic data
- ✅ Error handling in place
- ✅ App running on device

**Current Status**: The app now fetches real data from Supabase instead of showing hardcoded content. Just add data to your `social_feed` table and it will appear in the app!
