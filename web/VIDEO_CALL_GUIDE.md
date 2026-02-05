# 🎥 Video Call Test - Xpiano Web Demo

## ✅ ĐÃ TÍCH HỢP XONG!

Video call P2P đã được tích hợp hoàn chỉnh vào Next.js demo với 2 giao diện riêng biệt.

---

## 🚀 CÁCH TEST (2 THIẾT BỊ)

### **Bước 1: Chạy server**
```bash
cd d:\Xpiano\web-demo
npm run dev
```
Server sẽ chạy tại: http://localhost:3000

### **Bước 2: Mở trên PC (Học viên)**
1. Mở browser trên PC: **http://localhost:3000/classroom**
2. Click nút **"Tạo lớp học mới (Student)"**
3. Cho phép Camera/Mic
4. Sẽ thấy **Session ID** hiện trên màn hình (vd: `abc12345`)

### **Bước 3: Share link cho điện thoại (Giáo viên)**

**Có 2 cách:**

#### **Cách 1: Local Network (Nhanh nhất - Chỉ cần cùng Wifi)**
1. Kiểm tra IP máy PC:
   ```bash
   ipconfig
   # Tìm dòng IPv4 Address, vd: 192.168.1.100
   ```

2. Trên điện thoại (cùng Wifi), mở browser:
   ```
   http://192.168.1.100:3000/classroom
   ```

3. Chọn **"Tham gia như Giáo viên"**
4. Nhập Session ID (vd: `abc12345`)
5. Click **"Tham gia (Teacher)"**

#### **Cách 2: Deploy lên Internet (Nếu muốn test qua 4G/5G)**
```bash
# Cài Vercel CLI
npm install -g vercel

# Deploy
cd d:\Xpiano\web-demo
vercel

# Nhận link: https://xpiano-xxx.vercel.app
```

Sau đó mở link trên điện thoại.

---

## 📱 DEMO FLOW

### **Màn hình PC (Student):**
- ✅ Video local (mặt học viên)
- ✅ Video remote (mặt giáo viên sau khi kết nối)
- ✅ Session ID để share
- ✅ Chat với giáo viên
- ✅ Controls: Mute/Unmute, Camera On/Off, End Class

### **Màn hình Phone (Teacher):**
- ✅ Video local (mặt giáo viên)
- ✅ Video remote (mặt học viên sau khi kết nối)
- ✅ Lesson info
- ✅ Chat với học viên
- ✅ Controls: Mute/Unmute, Camera On/Off, End Class

### **Kết nối tự động:**
- Sau khi cả 2 vào phòng
- Đợi 2-5 giây
- Video tự động kết nối P2P
- Không cần bấm "Connect" thủ công!

---

## 🎯 PAGES ĐÃ TẠO

### 1. `/classroom`
Landing page để tạo/join session

### 2. `/classroom/student/[sessionId]`
Giao diện học viên (màu xanh dương)

### 3. `/classroom/teacher/[sessionId]`
Giao diện giáo viên (màu tím)

---

## 🔧 TECHNICAL DETAILS

### **Technology:**
- Next.js 14 (App Router)
- PeerJS (P2P WebRTC)
- TypeScript
- Custom React Hook (useVideoChat)

### **Features:**
- ✅ P2P video call (không qua server)
- ✅ Auto-connect khi cả 2 vào phòng
- ✅ Mute/Unmute mic
- ✅ Camera on/off
- ✅ Real-time chat (UI only)
- ✅ Session sharing
- ✅ Responsive mobile/desktop
- ✅ Dark mode UI

### **Files Created:**
```
web-demo/
├── app/
│   └── classroom/
│       ├── page.tsx                    # Landing page
│       ├── student/[sessionId]/page.tsx # Student UI
│       └── teacher/[sessionId]/page.tsx # Teacher UI
├── hooks/
│   └── useVideoChat.ts                 # Custom hook
├── types/
│   └── peerjs.d.ts                     # Type definitions
└── components/
    ├── Navbar.tsx (updated)
    └── PeerJSProvider.tsx
```

---

## ⚠️ TROUBLESHOOTING

### ❌ "Camera không hiện"
**Giải pháp:** 
- Refresh page
- Check console (F12) xem lỗi gì
- Cho phép quyền Camera/Mic trong browser settings

### ❌ "Không kết nối được giữa 2 thiết bị"
**Nguyên nhân:** PeerJS server free có thể quá tải  
**Giải pháp:**
- Đợi 10-30 giây
- Refresh cả 2 trang
- Thử lại

### ❌ "Phone không truy cập được localhost"
**Nguyên nhân:** Phone không thể truy cập `localhost:3000` của PC  
**Giải pháp:**
- Dùng IP local (Cách 1 ở trên)
- Hoặc deploy lên Vercel (Cách 2)

### ❌ "Hú hồi âm"
**Giải pháp:** Click nút 🔇 Mute trên 1 trong 2 thiết bị

---

## 🎉 NEXT STEPS

Để nâng cấp thành production:
1. ✅ Setup PeerJS server riêng (thay vì dùng free server)
2. ✅ Implement real chat (WebSocket)
3. ✅ Add recording feature
4. ✅ Add screen sharing
5. ✅ Integrate MIDI (như trong system overview)
6. ✅ Add authentication
7. ✅ Save session history

---

## 📞 READY TO TEST!

Server đang chạy tại: http://localhost:3000

**Mở ngay:** http://localhost:3000/classroom

Chúc bạn test thành công! 🚀
