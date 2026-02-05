# 🎥 HƯỚNG DẪN DEPLOY VIDEO CALL TEST - 3 CÁCH NHANH NHẤT

## ⚡ CÁCH 1: NETLIFY DROP (KHUYẾN NGHỊ - 30 GIÂY)

### Bước 1: Truy cập Netlify Drop
```
https://app.netlify.com/drop
```

### Bước 2: Drag & Drop
- Kéo file `video-call-test.html` vào vùng "Drag and drop your site folder here"
- HOẶC click "browse to upload" và chọn file

### Bước 3: Đợi 10 giây
- Netlify tự động deploy
- Bạn sẽ nhận được link dạng: `https://random-name-12345.netlify.app`

### Bước 4: Test
- Mở link trên điện thoại
- Copy My ID
- Nhập vào PC để kết nối

### ✅ ƯU ĐIỂM:
- ✨ NHANH NHẤT - 30 giây
- 🔒 HTTPS mặc định (bắt buộc cho WebRTC mobile)
- 🎯 Không cần đăng ký (có thể dùng anonymous)
- 🚀 CDN toàn cầu

---

## ⚡ CÁCH 2: SURGE.SH (40 GIÂY)

### Bước 1: Cài Surge CLI (chỉ lần đầu)
```powershell
npm install -g surge
```

### Bước 2: Deploy
```powershell
cd "d:\Xpiano\web-demo"
surge video-call-test.html
```

### Bước 3: Làm theo hướng dẫn
```
   email: (nhập email của bạn - chỉ lần đầu)
   password: (tạo password - chỉ lần đầu)
   domain: (Enter để dùng random, hoặc nhập custom như: xpiano-test.surge.sh)
```

### Bước 4: Nhận link
```
   Success! - Published to https://xpiano-test.surge.sh
```

### ✅ ƯU ĐIỂM:
- ⚡ Rất nhanh - 40 giây
- 🔒 HTTPS mặc định
- 🎯 Custom domain miễn phí
- 🔄 Update dễ dàng (chỉ chạy lại `surge`)

---

## ⚡ CÁCH 3: VERCEL (1 PHÚT)

### Bước 1: Cài Vercel CLI (chỉ lần đầu)
```powershell
npm install -g vercel
```

### Bước 2: Deploy
```powershell
cd "d:\Xpiano\web-demo"
vercel video-call-test.html
```

### Bước 3: Làm theo hướng dẫn
```
? Set up and deploy "D:\Xpiano\web-demo"? [Y/n] y
? Which scope do you want to deploy to? (your-username)
? Link to existing project? [y/N] n
? What's your project's name? xpiano-video-call
? In which directory is your code located? ./
```

### Bước 4: Nhận link
```
✅ Production: https://xpiano-video-call.vercel.app
```

### ✅ ƯU ĐIỂM:
- 🚀 Tự động CI/CD nếu push lên GitHub sau này
- 🔒 HTTPS mặc định
- 📊 Analytics miễn phí
- 🎯 Custom domain miễn phí

---

## 🎯 SO SÁNH & LỰA CHỌN

| Tiêu chí | Netlify Drop | Surge | Vercel |
|----------|--------------|-------|--------|
| **Tốc độ** | ⭐⭐⭐⭐⭐ 30s | ⭐⭐⭐⭐ 40s | ⭐⭐⭐ 1 phút |
| **Cài đặt** | ✅ Không cần | ⚠️ Cần npm | ⚠️ Cần npm |
| **UI** | ✅ Drag & drop | ⚠️ CLI | ⚠️ CLI |
| **Custom domain** | ⚠️ Random | ✅ Miễn phí | ✅ Miễn phí |
| **Update** | ⚠️ Phải upload lại | ✅ `surge` | ✅ `vercel` |

### 🏆 KHUYẾN NGHỊ:
- **Lần đầu test nhanh:** Dùng **Netlify Drop** (không cần cài gì)
- **Development dài hạn:** Dùng **Surge** hoặc **Vercel**

---

## 🔧 TROUBLESHOOTING

### ❌ Lỗi "This site can't provide a secure connection"
**Nguyên nhân:** File HTML đang chạy local (`file://`)  
**Giải pháp:** Phải deploy lên hosting có HTTPS (làm theo 1 trong 3 cách trên)

### ❌ Lỗi "Permission denied" khi truy cập Camera
**Nguyên nhân:** Browser chặn quyền  
**Giải pháp:**
1. Chrome: Settings > Privacy and security > Site Settings > Camera/Microphone > Allow
2. Safari iOS: Settings > Safari > Camera/Microphone > Ask

### ❌ Video không hiện trên iOS
**Nguyên nhân:** Safari yêu cầu `playsinline` attribute  
**Giải pháp:** ✅ Đã có sẵn trong code (`<video playsinline>`)

### ❌ Peer connection failed
**Nguyên nhân:** PeerJS server free có thể quá tải  
**Giải pháp:** Đợi 30s rồi refresh, hoặc thử lúc khác

---

## 📱 CÁCH TEST TRÊN 2 THIẾT BỊ

### Kịch bản 1: PC ↔ Phone

1. **Trên PC:**
   - Mở link đã deploy
   - Đợi hiện My ID (vd: `abc123xyz`)
   - Click nút 📋 để copy ID

2. **Trên Phone:**
   - Mở link (scan QR hoặc gửi qua Messenger/Zalo)
   - Cho phép Camera/Mic
   - Nhập ID vừa copy (vd: `abc123xyz`)
   - Bấm **Connect**

3. **Kết quả:**
   - PC thấy video của Phone
   - Phone thấy video của PC
   - Âm thanh 2 chiều

### Kịch bản 2: Phone A ↔ Phone B

1. **Phone A:** Mở link → Copy My ID → Gửi cho Phone B qua chat
2. **Phone B:** Mở link → Paste ID → Connect
3. **Done!**

### 🔇 LƯU Ý QUAN TRỌNG:
- **Luôn bật MUTE** khi test 2 thiết bị gần nhau (tránh hú)
- Click nút 🔇 để mute/unmute
- Red button = Đã mute ✅

---

## 🚀 QUICK START (TÓM TẮT 30 GIÂY)

```bash
# Mở browser
https://app.netlify.com/drop

# Kéo thả file
video-call-test.html

# Copy link
https://random-name-12345.netlify.app

# Gửi cho thiết bị thứ 2
# Test xong!
```

---

## 📞 HỖ TRỢ

Nếu gặp vấn đề:
1. Kiểm tra console (F12 > Console) để xem lỗi
2. Đảm bảo 2 thiết bị đều có HTTPS
3. Thử browser khác (Chrome/Safari)
4. Check network: 4G/5G/Wifi ổn định

**Demo này hoàn toàn miễn phí, không giới hạn số lần test!** 🎉

---

**Made with ❤️ for Xpiano Team**  
Version 1.0 - Jan 2026
