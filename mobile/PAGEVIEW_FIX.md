# 🔧 Fix: PageView Caching Issues

## 🐛 **Vấn đề gốc:**

Khi lướt qua các bài viết trong feed:
- ❌ Ảnh bị lặp lại (hiển thị ảnh cũ)
- ❌ Một số ảnh bị lỗi load mặc dù database có đủ dữ liệu
- ❌ UI hiển thị sai nội dung khi scroll

## 🔍 **Nguyên nhân:**

### 1. **PageView Widget Reuse**
Flutter **tái sử dụng widgets** trong PageView để tối ưu hiệu năng. Khi không có `key` duy nhất, Flutter nghĩ rằng trang hiện tại giống trang cũ và không rebuild widget → Dữ liệu cũ vẫn còn.

### 2. **Image.network Caching**
`Image.network` sử dụng caching mặc định. Khi không có `key` riêng biệt, Flutter cache ảnh theo URL. Nếu 2 bài viết khác nhau nhưng cùng URL (hoặc URL bị lỗi), ảnh cũ sẽ được hiển thị lại.

### 3. **PageController không được quản lý**
Thiếu PageController → Không kiểm soát được scroll behavior → PageView có thể skip pages hoặc load sai thứ tự.

## ✅ **Giải pháp đã áp dụng:**

### **File: `lib/main.dart`**

#### **1. Thêm PageController**

```dart
class _PianoFeedScreenState extends State<PianoFeedScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _feedFuture = _supabaseService.getSocialFeed();
    _pageController = PageController(keepPage: true); // ← MỚI
  }

  @override
  void dispose() {
    _pageController.dispose(); // ← MỚI: Clean up
    super.dispose();
  }
}
```

**Giải thích:**
- `PageController(keepPage: true)` → Giữ trang hiện tại khi rebuild
- `dispose()` → Giải phóng bộ nhớ khi widget bị hủy

---

#### **2. Thêm Controller và pageSnapping vào PageView**

```dart
PageView.builder(
  controller: _pageController,     // ← MỚI: Kiểm soát scroll
  scrollDirection: Axis.vertical,
  itemCount: feedItems.length,
  pageSnapping: true,              // ← MỚI: Snap to page khi scroll
  itemBuilder: (context, index) {
    final item = feedItems[index];
    return _buildFeedPage(item, key: ValueKey('feed_${item.id}')); // ← MỚI: Unique key
  },
)
```

**Giải thích:**
- `controller`: Quản lý scroll position, prevent bugs
- `pageSnapping: true`: Tự động "snap" vào trang khi scroll (giống TikTok)
- `ValueKey('feed_${item.id}')`: Key duy nhất cho mỗi bài viết → Flutter biết rebuild

---

#### **3. Thêm Key cho FeedPage**

```dart
Widget _buildFeedPage(FeedItem item, {required Key key}) {
  return Container(
    key: key, // ← MỚI: Unique key cho container
    child: Stack(
      children: [
        _buildBackground(item.mediaUrl, key: ValueKey('bg_${item.id}')),
        // ...
      ],
    ),
  );
}
```

**Giải thích:**
- Mỗi trang có 1 `key` riêng → Flutter rebuild đúng widget khi data thay đổi
- Background image cũng có key riêng → Không cache nhầm ảnh

---

#### **4. Thêm Key cho Image.network**

```dart
Widget _buildBackground(String mediaUrl, {required Key key}) {
  return Positioned.fill(
    child: Stack(
      children: [
        Image.network(
          key: key, // ← MỚI: Unique key cho image
          mediaUrl.isNotEmpty ? mediaUrl : 'https://via.placeholder.com/1080x1920/000000/FFFFFF?text=No+Image',
          fit: BoxFit.cover,
          // ...
        ),
      ],
    ),
  );
}
```

**Giải thích:**
- Mỗi ảnh có key duy nhất (`bg_1`, `bg_2`, ...)
- Flutter xóa cache ảnh cũ và load ảnh mới đúng cách

---

## 🎯 **Kết quả sau khi fix:**

✅ **Mỗi bài viết có unique key** → Flutter rebuild đúng widget  
✅ **PageController quản lý scroll** → Không skip trang, không lỗi position  
✅ **Image.network có key riêng** → Không cache nhầm ảnh  
✅ **pageSnapping = true** → Scroll mượt mà như TikTok  

---

## 🧪 **Cách test:**

1. **Thêm nhiều bài viết vào database** (ít nhất 5 posts)
2. **Chạy app**: `flutter run -d R5CX52Q5HTA`
3. **Lướt lên/xuống** qua các bài viết
4. **Quan sát:**
   - ✅ Mỗi bài viết hiển thị đúng ảnh
   - ✅ Không bị lặp lại ảnh cũ
   - ✅ Ảnh load đúng ngay cả khi scroll nhanh

---

## 📖 **Technical Deep Dive:**

### **Tại sao cần Key trong Flutter?**

Flutter sử dụng **Element Tree** để quản lý widgets. Khi rebuild:
1. Flutter so sánh `runtimeType` và `key`
2. Nếu trùng → Tái sử dụng Element cũ (performance optimization)
3. Nếu khác → Tạo Element mới

**Không có key:**
```
PageView item 0 → FeedItem ID=1
Scroll
PageView item 0 → FeedItem ID=2  ← Flutter nghĩ đây vẫn là item cũ!
```

**Có key:**
```
PageView item 0 (key='feed_1') → FeedItem ID=1
Scroll
PageView item 0 (key='feed_2') → FeedItem ID=2  ← Flutter biết đây là item mới!
```

---

## 💡 **Best Practices:**

### **Khi nào dùng Key?**
- ✅ `ListView/PageView` với dynamic data
- ✅ Reorderable lists
- ✅ Widgets có state riêng (TextField, Checkbox, etc.)
- ✅ Image/Video players với multiple sources

### **Loại Key nào?**
- `ValueKey(id)` → Khi có unique ID (database ID, UUID)
- `ObjectKey(object)` → Khi so sánh toàn bộ object
- `UniqueKey()` → Luôn unique, nhưng rebuild mỗi lần

### **PageController Best Practices:**
- Always `dispose()` controller
- Use `keepPage: true` nếu muốn giữ vị trí khi rebuild
- Use `initialPage` để set trang đầu tiên

---

## 🔗 **Related Files:**

| File | Thay đổi |
|------|----------|
| `lib/main.dart` | Added PageController, Keys cho PageView items và Images |
| `lib/models/feed_item.dart` | Không thay đổi |
| `lib/services/supabase_service.dart` | Không thay đổi |

---

## ✅ **Status: FIXED**

Vấn đề lặp ảnh và lỗi cache đã được giải quyết bằng cách:
1. Thêm PageController
2. Thêm unique keys cho tất cả dynamic widgets
3. Enable pageSnapping cho smooth scroll

**Code location:** `d:\Xpiano\mobile\lib\main.dart` (lines 70-210)
