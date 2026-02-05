# 🎹 Xpiano Communication Hub - Hướng dẫn Test

## ✅ ĐÃ TẠO XONG FILE HTML ĐỘC LẬP

File: `xpiano-communication-hub.html`

---

## 🚀 CÁCH TEST (2 THIẾT BỊ)

### **Phương án 1: Test trên cùng 1 máy (Nhanh nhất)**

1. **Mở 2 trình duyệt khác nhau:**
   - Chrome: Mở file `xpiano-communication-hub.html`
   - Edge/Firefox: Mở cùng file đó

2. **Trình duyệt 1 (Teacher):**
   - Click nút **"👨‍🏫 Tôi là Giáo Viên"**
   - Cho phép Camera/Mic
   - Đợi kết nối

3. **Trình duyệt 2 (Student):**
   - Click nút **"🎓 Tôi là Học Viên"**
   - Cho phép Camera/Mic
   - Tự động kết nối với Teacher

4. **Test Chat:**
   - Gõ tin nhắn ở 1 bên → Hiện ngay ở bên kia
   - Tin nhắn của mình: Bên phải (màu tím)
   - Tin nhắn đối phương: Bên trái (màu xám)

5. **Test Video Call:**
   - Click nút **"📞 Bắt đầu buổi học"** ở 1 trong 2 bên
   - Video tự động bật cả 2 bên
   - Chat vẫn hoạt động bên cạnh video

---

### **Phương án 2: Test giữa PC và Điện thoại**

#### **Bước 1: Deploy file HTML lên Internet**

**Cách A: Dùng Netlify Drop (30 giây)**
```
1. Mở: https://app.netlify.com/drop
2. Kéo thả file xpiano-communication-hub.html vào
3. Nhận link: https://xxx.netlify.app
```

**Cách B: Dùng Surge (40 giây)**
```bash
# Cài Surge
npm install -g surge

# Deploy
surge xpiano-communication-hub.html

# Nhận link: https://xxx.surge.sh
```

#### **Bước 2: Test trên 2 thiết bị**

**PC:**
```
1. Mở link vừa deploy: https://xxx.netlify.app
2. Click "👨‍🏫 Tôi là Giáo Viên"
3. Cho phép Camera/Mic
```

**Phone:**
```
1. Mở cùng link: https://xxx.netlify.app
2. Click "🎓 Tôi là Học Viên"
3. Cho phép Camera/Mic
4. Tự động kết nối với PC
```

---

## 📋 TÍNH NĂNG

### ✅ **Chat Real-time**
- ✅ P2P qua PeerJS DataConnection
- ✅ Tin nhắn sync ngay lập tức
- ✅ UI giống Messenger (tin mình bên phải, đối phương bên trái)
- ✅ Tự động cuộn xuống tin mới nhất
- ✅ Hiển thị thời gian gửi

### ✅ **Video Call**
- ✅ HD 720p video
- ✅ Echo cancellation + Noise suppression
- ✅ Nút Mute/Unmute mic (🎤/🔇)
- ✅ Nút Bật/Tắt camera (📹/📹❌)
- ✅ Nút kết thúc cuộc gọi (đỏ)
- ✅ Video lớn (đối phương) + Video nhỏ (mình)
- ✅ Chat vẫn hoạt động khi đang video call

### ✅ **Giao diện**
- ✅ Dark mode với màu chủ đạo đen/tím
- ✅ Responsive (Mobile + Desktop)
- ✅ Animations mượt mà
- ✅ Status indicator (online/offline)
- ✅ System messages (kết nối, ngắt kết nối...)

### ✅ **Xử lý lỗi**
- ✅ Thông báo khi đối phương offline
- ✅ Auto-reconnect khi mất kết nối
- ✅ Xử lý lỗi camera/mic không cho phép
- ✅ Loading spinner khi đang kết nối

---

## 🎯 LUỒNG HOẠT ĐỘNG

### **1. Chọn vai trò**
```
Landing Screen
├─ Nút "Tôi là Giáo Viên" → ID: xpiano-teacher → Partner: xpiano-student
└─ Nút "Tôi là Học Viên" → ID: xpiano-student → Partner: xpiano-teacher
```

### **2. Auto-connect**
```
PeerJS Server
├─ Teacher register: xpiano-teacher
├─ Student register: xpiano-student
└─ Auto DataConnection giữa 2 ID cố định
```

### **3. Chat**
```
User A: Gõ tin nhắn → PeerJS DataConnection → User B: Nhận tin nhắn
├─ Type: "message"
├─ Text: "Nội dung"
└─ Timestamp: ISO 8601
```

### **4. Video Call**
```
User A: Click "Bắt đầu buổi học"
├─ Bật Camera/Mic (getUserMedia)
├─ Gửi "video-request" qua DataConnection
├─ peer.call(partnerPeerId, localStream)
└─ User B: Nhận stream → Hiển thị video
```

---

## ⚠️ TROUBLESHOOTING

### ❌ **"Đối phương đang offline"**
**Nguyên nhân:** 1 trong 2 người chưa mở web  
**Giải pháp:** Mở cả 2 thiết bị cùng lúc

### ❌ **"Camera không bật"**
**Nguyên nhân:** Browser chặn quyền Camera/Mic  
**Giải pháp:** 
- Click biểu tượng 🔒 trên thanh địa chỉ
- Cho phép Camera và Microphone
- Refresh trang

### ❌ **"Tin nhắn không gửi được"**
**Nguyên nhân:** DataConnection chưa mở  
**Giải pháp:** Đợi status indicator chuyển xanh (🟢 Online)

### ❌ **"Video bị đen"**
**Nguyên nhân:** 
- Camera đang được dùng bởi app khác
- Hoặc PeerJS server quá tải

**Giải pháp:**
- Tắt các app dùng camera (Zoom, Teams...)
- Đợi 10-30 giây rồi thử lại

### ❌ **"Hú hồi âm"**
**Giải pháp:** Click nút 🔇 Mute ở 1 trong 2 bên

---

## 🔧 TECHNICAL DETAILS

### **Technology Stack:**
- Pure HTML/CSS/JavaScript (Vanilla)
- PeerJS 1.5.2 (WebRTC wrapper)
- P2P architecture (no backend server)

### **PeerJS Server:**
- Free public server: `peerjs-server.herokuapp.com`
- Region: Auto (best latency)

### **STUN Servers:**
- `stun:stun.l.google.com:19302`
- `stun:stun1.l.google.com:19302`

### **Browser Compatibility:**
- ✅ Chrome 90+
- ✅ Edge 90+
- ✅ Firefox 88+
- ✅ Safari 14+ (iOS)
- ❌ IE (not supported)

---

## 📱 RECOMMENDED TEST SCENARIOS

### **Scenario 1: Cùng Wifi**
- PC: Teacher
- Phone: Student
- Expected: Latency < 100ms

### **Scenario 2: 4G vs Wifi**
- PC (Wifi): Teacher
- Phone (4G): Student
- Expected: Latency 100-300ms

### **Scenario 3: 2 Phone**
- Phone 1 (4G): Teacher
- Phone 2 (5G): Student
- Expected: Latency 150-400ms

---

## 🎉 READY TO TEST!

**File location:**
```
d:\Xpiano\xpiano-communication-hub.html
```

**Double click để mở hoặc:**
```bash
# Deploy lên Netlify Drop
https://app.netlify.com/drop

# Hoặc dùng local server
cd d:\Xpiano
python -m http.server 8000
# Mở: http://localhost:8000/xpiano-communication-hub.html
```

---

## 💡 TIPS

1. **Test nhanh nhất:** Mở 2 tab trong cùng 1 browser (Chrome), 1 tab Teacher + 1 tab Student
2. **Tránh echo:** Dùng tai nghe hoặc mute 1 trong 2 bên
3. **Video HD:** Đảm bảo đủ ánh sáng và camera chất lượng tốt
4. **Chat trong video:** Vẫn chat được khi đang video call (bên phải màn hình)

Chúc bạn test thành công! 🚀
