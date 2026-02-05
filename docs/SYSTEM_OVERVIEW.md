# XPIANO - TÀI LIỆU TỔNG QUAN HỆ THỐNG
## System Overview Documentation

**Version:** 1.0  
**Date:** January 31, 2026  
**Project:** Xpiano - Vietnam's First Music Ecosystem Platform  

---

## 📋 MỤC LỤC

1. [Tổng quan Dự án](#1-tổng-quan-dự-án)
2. [Kiến trúc Hệ thống](#2-kiến-trúc-hệ-thống)
3. [Luồng Người dùng](#3-luồng-người-dùng)
4. [Tech Stack Recommendation](#4-tech-stack-recommendation)
5. [Chiến lược Phát triển](#5-chiến-lược-phát-triển)
6. [Rủi ro và Giải pháp](#6-rủi-ro-và-giải-pháp)

---

## 1. TỔNG QUAN DỰ ÁN

### 1.1 Vision Statement
Xpiano là nền tảng hệ sinh thái âm nhạc đầu tiên tại Việt Nam giải quyết bài toán "phần cứng" trong giáo dục âm nhạc bằng cách kết nối 3 bên: Học viên, Giáo viên, và Kho đàn thông qua mô hình Sharing Economy.

### 1.2 Unique Selling Proposition (USP)
- **Hardware-as-a-Service**: Cho thuê đàn piano/keyboard ship tận nhà
- **Real-time MIDI Learning**: Kết nối đàn thực với app qua MIDI để nhận feedback trực tiếp
- **Live Online Classes**: Video call + MIDI streaming cho trải nghiệm học như offline
- **Ecosystem Approach**: Không chỉ là app học nhạc, mà là marketplace kết nối toàn bộ chuỗi giá trị

### 1.3 Stakeholders
| Đối tượng | Nhu cầu | Giá trị nhận được |
|-----------|---------|-------------------|
| **Học viên** | Học đàn nhưng không có đàn | Thuê đàn giá rẻ + Học online chất lượng |
| **Giáo viên** | Tìm học viên + Công cụ dạy online | Nền tảng kết nối + Tool dạy MIDI real-time |
| **Kho đàn** | Tối ưu hóa đàn nhàn rỗi | Doanh thu cho thuê + Marketing |

---

## 2. KIẾN TRÚC HỆ THỐNG

### 2.1 High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────┐      ┌─────────────┐      ┌─────────────┐         │
│  │   Student   │      │   Teacher   │      │   Partner   │         │
│  │  Mobile App │      │  Mobile App │      │  Web Portal │         │
│  │  (iOS/And)  │      │  (iOS/And)  │      │  (Desktop)  │         │
│  └──────┬──────┘      └──────┬──────┘      └──────┬──────┘         │
│         │                    │                     │                 │
└─────────┼────────────────────┼─────────────────────┼─────────────────┘
          │                    │                     │
          │                    │                     │
┌─────────┼────────────────────┼─────────────────────┼─────────────────┐
│         │         API GATEWAY & LOAD BALANCER      │                 │
│         └────────────────────┬─────────────────────┘                 │
└──────────────────────────────┼───────────────────────────────────────┘
                               │
┌──────────────────────────────┼───────────────────────────────────────┐
│                      BACKEND SERVICES LAYER                          │
├──────────────────────────────┼───────────────────────────────────────┤
│                              │                                        │
│  ┌───────────────────────────┴──────────────────────────┐           │
│  │             Main Backend (Node.js/NestJS)             │           │
│  │                                                        │           │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐           │           │
│  │  │   Auth   │  │  User    │  │ Booking  │           │           │
│  │  │ Service  │  │ Service  │  │ Service  │           │           │
│  │  └──────────┘  └──────────┘  └──────────┘           │           │
│  │                                                        │           │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐           │           │
│  │  │ Payment  │  │ Logistics│  │ Matching │           │           │
│  │  │ Service  │  │ Service  │  │ Service  │           │           │
│  │  └──────────┘  └──────────┘  └──────────┘           │           │
│  └────────────────────────────────────────────────────────┘          │
│                                                                       │
│  ┌────────────────────────────────────────────────────────┐          │
│  │      Real-time Services (WebSocket/WebRTC)             │          │
│  │                                                         │          │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │          │
│  │  │   MIDI   │  │  Video   │  │  Chat    │            │          │
│  │  │ Streaming│  │  Call    │  │ Service  │            │          │
│  │  └──────────┘  └──────────┘  └──────────┘            │          │
│  └────────────────────────────────────────────────────────┘          │
│                                                                       │
│  ┌────────────────────────────────────────────────────────┐          │
│  │         AI & Analytics Services (Python)               │          │
│  │                                                         │          │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐            │          │
│  │  │   MIDI   │  │ Practice │  │  Recom-  │            │          │
│  │  │ Analysis │  │ Analytics│  │ mendation│            │          │
│  │  └──────────┘  └──────────┘  └──────────┘            │          │
│  └────────────────────────────────────────────────────────┘          │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
                               │
┌──────────────────────────────┼───────────────────────────────────────┐
│                       DATA LAYER                                     │
├──────────────────────────────┼───────────────────────────────────────┤
│                              │                                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │PostgreSQL│  │  Redis   │  │ MongoDB  │  │   S3     │            │
│  │(Primary) │  │ (Cache)  │  │  (Logs)  │  │ (Files)  │            │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘            │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
                               │
┌──────────────────────────────┼───────────────────────────────────────┐
│                    EXTERNAL SERVICES                                 │
├──────────────────────────────┼───────────────────────────────────────┤
│                                                                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │ Payment  │  │ Shipping │  │   SMS    │  │  Push    │            │
│  │ Gateway  │  │   API    │  │ Provider │  │  Notif.  │            │
│  │(VNPay/   │  │(Giao Hàng│  │(Twilio/  │  │(Firebase)│            │
│  │ Momo)    │  │  Nhanh)  │  │ Viettel) │  │          │            │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘            │
│                                                                       │
└───────────────────────────────────────────────────────────────────────┘
```

### 2.2 Core Data Flow - Đặt Thuê Đàn (E-commerce Flow)

#### Flow Diagram:
```
Student App                 Backend              Partner Portal        External
─────────────────────────────────────────────────────────────────────────────

1. Browse Pianos
   │
   ├──[GET]──────────>  Piano Service
   │                    │
   │                    ├─Query─> PostgreSQL
   │                    │          (Available pianos)
   │<─────[200]─────────┤
   │  (Piano List)

2. Select & Checkout
   │
   ├──[POST]─────────>  Booking Service
   │  (Piano ID,         │
   │   Dates, Address)   │
   │                     ├─Validate─> Piano Availability
   │                     │
   │                     ├─Calculate─> Pricing Logic
   │                     │              (Duration, Insurance)
   │                     │
   │                     ├─Create──> Booking (PENDING)
   │                     │             PostgreSQL
   │<─────[201]─────────┤
   │  (Booking ID)

3. Payment
   │
   ├──[POST]─────────>  Payment Service
   │  (Booking ID)       │
   │                     ├─Generate─────────────────> VNPay/Momo
   │<─────[200]─────────┤                              (Payment URL)
   │  (Payment URL)      │
   │                     │
   ├─Redirect to────────┴───────────────────────────> VNPay Web
   │  Payment Page
   │
   User pays on VNPay
   │
   │<─────Callback──────────────────────────────────  VNPay IPN
   │                     │
   │                  Payment Service
   │                     ├─Update─> Booking (PAID)
   │                     │
   │                     ├─Trigger─> Notification Service
   │                     │            (SMS/Push to Student)
   │                     │
   │                     └─Notify──────────────────> Partner Portal
   │                                                  (New Order Alert)

4. Partner Confirms
                                                      Partner Portal
                                                         │
                                     [PUT]──────────────┤
                                     Booking Service <──┘
                                        │              (Confirm Delivery)
                                        │
                                        ├─Update─> Booking (CONFIRMED)
                                        │
                                        ├─Call────────────────> Shipping API
                                        │                       (Create Order)
                                        │
                                        └─Push──> Student App
                                                  (Tracking Info)

5. Delivery
   Student App <─────Push───────── Shipping Webhook
                                   (Status Updates)
                                   
6. Confirm Receipt
   │
   ├──[POST]─────────>  Booking Service
   │  (Booking ID,      │
   │   Confirm Received)│
   │                    ├─Update─> Booking (ACTIVE)
   │                    │
   │                    ├─Unlock─> MIDI Connection
   │                    │           (Device Pairing)
   │                    │
   │<─────[200]────────┤
   │  (Success)
```

#### Business Logic Details:

**Pricing Calculation:**
```javascript
// Pseudocode
total_price = (daily_rate × rental_days) + insurance_fee + shipping_fee
insurance_fee = piano_value × 0.05 × (rental_days / 30)
shipping_fee = distance < 10km ? 50000 : 100000
discount = apply_promotions(user, season, referral)
final_price = total_price - discount
```

**Booking States:**
```
PENDING → PAID → CONFIRMED → IN_TRANSIT → ACTIVE → RETURNED → COMPLETED
         ↓
      CANCELLED (if payment fails or partner rejects)
```

---

### 2.3 Core Data Flow - Lớp Học Online (Real-time Learning)

#### Flow Diagram:
```
Student App          Teacher App         Real-time Server      AI Service
────────────────────────────────────────────────────────────────────────

1. Schedule Class
   │
   ├──[POST]────────> Booking Service
   │  (Teacher ID,     │
   │   Time Slot)      │
   │                   ├─Check─> Teacher Availability
   │                   │
   │                   ├─Create─> Class Session (SCHEDULED)
   │                   │
   │                   └─Notify──────────> Teacher App
   │                                       (New Booking)

2. Join Class (5 mins before)
   │
   ├──[WebSocket]───> Session Service
   │  CONNECT          │
   │                   ├─Authenticate─> JWT Verify
   │                   │
   │                   ├─Create─> Room (Session ID)
   │                   │           Redis (Temp State)
   │                   │
   │<──[Connected]────┤
   │  (Room ID)
                       │
                       │            Teacher App
                       │                │
                       │<──[WebSocket]──┤
                       │    CONNECT
                       │                
                       └──[Notify]────> Student + Teacher
                                        (Both in room)

3. Video Call Setup
   │
   ├──[WebRTC]─────> Video Service
   │  OFFER            │
   │                   ├─Relay─────────────────> Teacher App
   │                   │                          OFFER
   │                   │
   │                   │<──────────────────────  ANSWER
   │<──[WebRTC]───────┤
   │  ANSWER
   │
   ╔═══════════════════════════════════════════════════════════╗
   ║          P2P Video Stream (WebRTC Direct)                 ║
   ║  Student <──────────────────────────────────> Teacher     ║
   ╚═══════════════════════════════════════════════════════════╝

4. MIDI Streaming
   │
   Student plays piano
   │
   ├──[MIDI Data]───> MIDI Service (WebSocket)
   │  {                 │
   │   note: 60,        │
   │   velocity: 80,    ├─Forward────────────> Teacher App
   │   timestamp: xxx   │                     (Real-time Display)
   │  }                 │
   │                    │
   │                    ├─Buffer─> Redis (Last 100 events)
   │                    │
   │                    └─Async Send─────────────> AI Service
   │                                               (Analysis Queue)

5. AI Analysis (Async)
                                                   AI Service
                                                      │
                                                      ├─Analyze MIDI:
                                                      │  • Timing accuracy
                                                      │  • Note correctness
                                                      │  • Dynamics
                                                      │
                                                      ├─Generate Feedback
                                                      │
                                                      └─Send Result──>
                       │
   Student App <───────┤ WebSocket Push
   Teacher App <───────┤ (Analysis Result)
                       
6. Teacher Feedback
                       Teacher App
                          │
   [Drawing/Annotation]───┤
                          │
                  MIDI Service
                     │
                     ├─Broadcast────────────> Student App
                     │                        (Overlay Display)
                     │
                     └─Record─> PostgreSQL
                                (Lesson Log)

7. End Class
   │
   ├──[POST]────────> Session Service
   │  END_SESSION      │
   │                   ├─Calculate─> Duration, Quality Score
   │                   │
   │                   ├─Update─> Class (COMPLETED)
   │                   │
   │                   ├─Process Payment─> Teacher Wallet
   │                   │
   │                   ├─Generate─> Practice Report
   │                   │             (AI Summary)
   │                   │
   │<──[200]──────────┤
      (Report ID)
```

#### Technical Specifications:

**WebSocket Message Protocol:**
```javascript
// MIDI Event
{
  type: "midi_event",
  session_id: "uuid",
  timestamp: 1738310400000,
  user_id: "student_123",
  data: {
    command: "note_on", // note_on, note_off, control_change
    channel: 0,
    note: 60, // C4
    velocity: 80,
    duration: 500 // ms (for note_off)
  }
}

// Analysis Result
{
  type: "analysis_result",
  session_id: "uuid",
  timestamp: 1738310401000,
  data: {
    accuracy: 0.85,
    timing_score: 0.90,
    notes_correct: 45,
    notes_total: 50,
    feedback: "Good job! Focus on dynamics in measures 3-4"
  }
}
```

**Latency Requirements:**
- MIDI Event Delivery: < 50ms (P99)
- Video Call: < 150ms (P95)
- AI Analysis: < 2s (Async, acceptable delay)

**Scalability Strategy:**
- WebSocket Server: Sticky sessions with Redis pub/sub
- MIDI Service: Horizontal scaling with room-based sharding
- Video: P2P WebRTC (Server only for signaling, not media)

---

## 3. LUỒNG NGƯỜI DÙNG (USER JOURNEY MAP)

### 3.1 Student Journey - "First Time Learning"

#### Persona:
- **Tên:** Minh (Nữ, 22 tuổi)
- **Background:** Sinh viên đại học, thích âm nhạc nhưng chưa học chính thức
- **Pain Point:** Muốn học piano nhưng không có đàn và không biết bắt đầu từ đâu
- **Goal:** Học được bài đầu tiên trong 1 tuần

---

#### 🎯 Phase 1: Discovery & Sign Up (Day 1 - Morning)

**Touchpoint:** Google Search / Facebook Ad / Word of Mouth

**Actions:**
1. **Tìm kiếm:** "học đàn piano online giá rẻ"
2. **Landing Page:** Thấy Xpiano quảng cáo "Thuê đàn + Học online chỉ từ 500k/tháng"
3. **Download App:** iOS App Store / Google Play
4. **Open App:** Welcome screen giới thiệu 3 bước: Thuê đàn → Kết nối → Học

**UI Flow:**
```
┌─────────────────────┐
│  Welcome Screen 1   │
│  🎹 "Học đàn không   │
│     cần mua đàn"    │
│                     │
│    [Tiếp tục] ──────┼──> Screen 2: "Chọn đàn phù hợp"
└─────────────────────┘    ──> Screen 3: "Học với thầy cô chuyên nghiệp"
                               ──> [Bắt đầu ngay]
```

5. **Sign Up:**
   - Nhập SĐT: 0912345678
   - Nhận OTP: 123456
   - Điền thông tin:
     - Tên: Minh
     - Tuổi: 22
     - Mục tiêu: "Học để giải trí"
     - Trình độ: "Chưa biết gì"

**System Actions:**
- Tạo User Profile (ID: user_123)
- Tag persona: "Beginner + Casual Learner"
- Show personalized onboarding: "Khóa học cơ bản cho người mới"

**Emotional State:** 🙂 Tò mò, hồi hộp

---

#### 🎹 Phase 2: Piano Rental (Day 1 - Afternoon)

**Touchpoint:** In-App Piano Marketplace

**Actions:**
1. **Browse Pianos:**
   - Tab "Thuê đàn" hiện danh sách:
     - Yamaha P-45 (500k/tháng)
     - Casio CDP-S110 (450k/tháng)
     - Roland FP-10 (650k/tháng)
   - Filter: "Gần tôi" (Chọn quận Cầu Giấy, Hà Nội)

2. **View Details:**
   - Click Yamaha P-45:
     - Ảnh 360°
     - Spec: 88 phím, có MIDI USB
     - Reviews: 4.8⭐ (127 đánh giá)
     - Kho: "Piano Store HN" (2.3km)
     - Giá:
       - 1 tháng: 500k
       - 3 tháng: 1.35 triệu (giảm 10%)
       - 6 tháng: 2.4 triệu (giảm 20%)

3. **Chọn gói:**
   - Chọn: "3 tháng - 1.35 triệu"
   - Chọn ngày nhận: "Ngày mai (01/02/2026)"
   - Nhập địa chỉ: "Số 123, Đường Xuân Thủy, Cầu Giấy, HN"
   - Chọn thêm:
     - ✅ Bảo hiểm (50k)
     - ✅ Cáp MIDI-USB (100k)
     - ❌ Sustain Pedal (không cần)

4. **Checkout:**
   - Tổng: 1.5 triệu
   - Mã giảm giá: "NEWUSER" (-100k)
   - **Final: 1.4 triệu**
   - Thanh toán: Chọn "Momo"

5. **Payment:**
   - App chuyển sang Momo
   - Xác nhận thanh toán
   - Quay lại app → "Đặt hàng thành công!"

**System Actions:**
- Booking ID: BK_001 (Status: PAID)
- Notify Partner: "Đơn hàng mới - Ship trước 18h ngày mai"
- SMS to Minh: "Đàn của bạn sẽ đến vào 01/02, 14:00-16:00"

**Emotional State:** 😊 Phấn khích, mong chờ

---

#### 📦 Phase 3: Piano Delivery (Day 2 - 15:00)

**Touchpoint:** Push Notification + SMS

**Actions:**
1. **Morning:**
   - Nhận push: "Shipper đã lấy hàng, dự kiến đến 15:00"
   - Xem tracking: "Đang trên đường giao hàng"

2. **15:30 - Delivery:**
   - Shipper gọi điện
   - Nhận đàn + Kiểm tra:
     - Đàn còn nguyên vẹn ✅
     - Đầy đủ phụ kiện ✅
   - Ký nhận trên app shipper

3. **Confirm Receipt (In-App):**
   - Push notification: "Bạn đã nhận đàn chưa?"
   - Click "Đã nhận hàng"
   - Đánh giá trải nghiệm giao hàng: 5⭐

**System Actions:**
- Booking Status: PAID → ACTIVE
- Unlock MIDI pairing feature
- Auto-suggest: "Kết nối đàn ngay để bắt đầu học!"

**Emotional State:** 😃 Rất vui, hào hứng

---

#### 🔌 Phase 4: Piano Connection (Day 2 - 16:00)

**Touchpoint:** In-App Tutorial

**Actions:**
1. **Click "Kết nối đàn":**
   - Tutorial video (30s):
     - "Cắm cáp USB từ đàn vào điện thoại"
     - "Nếu dùng iPhone, cần adapter Lightning-to-USB"

2. **Plug in Cable:**
   - Minh cắm cáp MIDI-USB vào đàn
   - Cắm đầu USB-C vào điện thoại Android

3. **App Auto-Detect:**
   - "Phát hiện Yamaha P-45!"
   - "Đang kết nối..."
   - ✅ "Kết nối thành công!"

4. **Test Connection:**
   - App hiện piano ảo trên màn hình
   - Nhắc: "Hãy thử bấm 1 phím bất kỳ"
   - Minh bấm phím C
   - App sáng lên phím C → "Hoàn hảo! 🎉"

**System Actions:**
- Device Pairing: user_123 ↔ Piano SN: YMH_P45_12345
- Log first MIDI event
- Trigger achievement: "🎖️ Kết nối thành công - Nhận 50 XP"

**Emotional State:** 🤩 Ngạc nhiên, ấn tượng với công nghệ

---

#### 👩‍🏫 Phase 5: Book First Lesson (Day 2 - 17:00)

**Touchpoint:** In-App Teacher Marketplace

**Actions:**
1. **App Suggest:**
   - Pop-up: "Sẵn sàng học bài đầu tiên chưa?"
   - Options:
     - [Học với giáo viên] → Recommended
     - [Tự học với AI]

2. **Chọn "Học với giáo viên":**
   - Danh sách giáo viên:
     - Cô Hương (8 năm KN, 4.9⭐, 250k/buổi)
     - Thầy Tuấn (5 năm KN, 4.7⭐, 200k/buổi)
     - Cô Linh (10 năm KN, 5.0⭐, 300k/buổi)
   - Filter: "Có slot tối nay"

3. **Chọn Cô Hương:**
   - Xem profile:
     - Video giới thiệu
     - Chuyên môn: "Dạy người mới bắt đầu"
     - Reviews: "Cô dạy rất kiên nhẫn và dễ hiểu"
   - Xem lịch:
     - Tối nay: 20:00 ✅ Available
     - Ngày mai: 18:00, 20:00 ✅

4. **Book:**
   - Chọn: "Hôm nay, 20:00, 1 tiếng"
   - Giá: 250k
   - Note: "Em chưa biết gì về đàn cả ạ"
   - [Đặt lịch]

5. **Payment:**
   - Dùng Momo (đã liên kết)
   - Thanh toán thành công

**System Actions:**
- Class Session: CS_001 (Status: SCHEDULED)
- Notify Teacher Hương: "Học viên mới đã book buổi học 20:00"
- Send Minh reminder: "Buổi học bắt đầu lúc 20:00, chuẩn bị sẵn đàn nhé!"

**Emotional State:** 😊 Hồi hộp nhưng tin tưởng

---

#### 🎓 Phase 6: First Online Lesson (Day 2 - 20:00)

**Touchpoint:** In-App Live Classroom

**Actions:**

**19:55 - Pre-class:**
- Push notification: "Buổi học sắp bắt đầu!"
- Click vào → "Phòng chờ"
- Checklist:
  - ✅ Đàn đã kết nối
  - ✅ Micro/Camera OK
  - ✅ Mạng ổn định (50 Mbps)

**20:00 - Class Starts:**
1. **Join Room:**
   - Cô Hương xuất hiện trên video
   - "Chào em Minh! Em thấy cô rõ không?"
   - Minh: "Dạ rõ ạ!"

2. **Teacher Introduction (5 mins):**
   - Cô Hương: "Hôm nay chúng ta sẽ học về tư thế ngồi và vị trí ngón tay"
   - Share screen: Hiển thị ảnh tư thế đúng

3. **Hands Position Lesson (10 mins):**
   - Cô: "Em thử đặt ngón tay lên phím C-D-E-F-G"
   - Minh đặt tay
   - **App hiển thị:**
     - Piano view trên màn hình
     - Overlay: "✅ Ngón 1 (C), ✅ Ngón 2 (D)..."
   - Cô: "Tốt lắm! Giờ em bấm từng phím một"

4. **First Exercise - C Scale (20 mins):**
   - Cô chơi mẫu: C-D-E-F-G-F-E-D-C
   - MIDI của cô được gửi sang màn hình Minh
   - App highlight: "Hãy bấm theo các phím sáng lên"
   - Minh chơi:
     - C ✅
     - D ✅
     - E ✅
     - F ❌ (bấm E nhầm)
   - App thông báo: "⚠️ Sai phím, thử lại"
   - Cô: "Không sao, em thử lại từ từ"
   - Minh chơi lại → ✅ Hoàn thành!

5. **Real-time Feedback (15 mins):**
   - Minh luyện tập scale nhiều lần
   - AI Analysis (hiển thị cuối buổi):
     - Timing Accuracy: 75%
     - Note Correctness: 90%
     - Suggestion: "Tốc độ đều hơn ở nốt F-G"

6. **Homework Assignment (5 mins):**
   - Cô: "Về nhà em luyện scale này 10 lần mỗi ngày nhé"
   - App tự động thêm vào "Practice Goals":
     - ✅ C Major Scale × 10 lần/ngày
     - Deadline: 1 tuần

7. **End Class (20:55):**
   - Cô: "Em học rất tốt! Hẹn buổi sau nhé!"
   - Minh: "Cảm ơn cô ạ!"
   - [End Call]

**Post-Class:**
- App hiện pop-up:
  - "Đánh giá buổi học: ⭐⭐⭐⭐⭐"
  - "Cô Hương dạy thế nào?"
  - Minh: 5⭐ "Cô dạy rất dễ hiểu!"

- Practice Report Generated:
  - Duration: 55 mins
  - Notes Played: 127
  - Accuracy: 85%
  - Achievement: "🎖️ Buổi học đầu tiên - Nhận 100 XP"

**System Actions:**
- Class Status: SCHEDULED → COMPLETED
- Payment released to Teacher Hương (250k - 20% platform fee)
- Suggest: "Book buổi tiếp theo với Cô Hương?"

**Emotional State:** 🥰 Rất hài lòng, tự tin hơn

---

#### 📈 Phase 7: Practice & Retention (Day 3-7)

**Touchpoint:** Daily Reminders + Gamification

**Actions:**

**Day 3:**
- 10:00: Push "Đã luyện tập chưa? 🎹"
- Minh mở app → "Practice Mode"
- Chọn "C Major Scale"
- App đếm: "1/10 lần"
- Chơi 5 lần → "5/10 - Cố lên! 💪"

**Day 4:**
- Streak: "🔥 2 ngày liên tiếp!"
- Unlock achievement: "Learner - 50 XP"
- Leaderboard: "Bạn xếp #127 trong tuần này"

**Day 5:**
- App suggest: "Thử bài mới? 'Ode to Joy' dễ lắm đấy!"
- Minh thử → Quá khó
- Back to scale

**Day 7:**
- Completed goal: "✅ C Major Scale × 70 lần"
- Reward: "🎁 Giảm 50k buổi học tiếp theo"
- Notification: "Đặt lịch buổi 2 với Cô Hương ngay!"

**Emotional State:** 😌 Hài lòng, có động lực tiếp tục

---

### 3.2 Key Touchpoints Summary

| Phase | Touchpoint | Duration | Key Metric | Success Criteria |
|-------|-----------|----------|------------|------------------|
| Discovery | Landing Page | 2 mins | CTR > 5% | User clicks "Download" |
| Sign Up | Onboarding | 3 mins | Completion Rate > 80% | Profile created |
| Piano Rental | Marketplace | 10 mins | Conversion Rate > 15% | Booking placed |
| Delivery | Logistics | 1 day | On-time Rate > 95% | Piano received |
| Connection | Setup Tutorial | 5 mins | Success Rate > 90% | MIDI connected |
| First Lesson | Live Class | 60 mins | Completion Rate > 95% | Class finished |
| Retention | Practice Reminders | 7 days | D7 Retention > 40% | User active |

---

## 4. TECH STACK RECOMMENDATION

### 4.1 Frontend Strategy: Web-First → Mobile App

#### Phase 1: **Web Application (Progressive Web App)**

**Why Web First?**
- ✅ **Faster Time-to-Market:** Deploy ngay, không cần App Store approval (2-4 tuần)
- ✅ **Easy Testing:** Share link test với users, iterate nhanh
- ✅ **Lower Cost:** 1 codebase, không cần native developers
- ✅ **Universal Access:** Chạy trên mọi device có browser
- ✅ **SEO Benefits:** Google index được → Organic traffic
- ✅ **No Installation Friction:** Users dùng thử không cần cài app

#### Recommended: **Next.js 14** (React Framework) + PWA

**Why Next.js?**
- ✅ **Full-stack Framework:** API routes + Frontend trong 1 project
- ✅ **SSR/SSG:** Fast loading, SEO-friendly
- ✅ **Server Actions:** Easy form handling, data mutations
- ✅ **Progressive Web App:** Install được như native app
- ✅ **Large Ecosystem:** Nhiều UI libraries (shadcn/ui, Tailwind)
- ✅ **Vercel Hosting:** Deploy free với auto-scaling

**Key Dependencies (Web MVP):**
```json
{
  "dependencies": {
    "next": "^14.x",
    "react": "^18.x",
    "@tanstack/react-query": "^5.x",    // API caching
    "zustand": "^4.x",                   // State management
    "socket.io-client": "^4.x",          // WebSocket
    "@webrtc/sdk": "latest",             // Video Call
    "webmidi": "^3.x",                   // Web MIDI API
    "framer-motion": "^11.x",            // Animations
    "tailwindcss": "^3.x",               // Styling
    "shadcn/ui": "latest",               // UI Components
    "react-hook-form": "^7.x",           // Forms
    "zod": "^3.x"                        // Validation
  }
}
```

**PWA Features:**
- Add to Home Screen (giống native app)
- Offline mode (Service Worker)
- Push notifications (Web Push API)
- Camera/Mic access (WebRTC)
- MIDI device access (Web MIDI API)

---

#### Phase 2: **Flutter Mobile App** (iOS + Android)

**Why Flutter (for mobile phase)?**
- ✅ **True Cross-Platform:** Single codebase cho iOS + Android
- ✅ **Native Performance:** Compiled to ARM code, smooth 60fps
- ✅ **Hot Reload:** Fast development cycle
- ✅ **Beautiful UI:** Material + Cupertino widgets built-in
- ✅ **Growing Ecosystem:** Good MIDI, WebRTC packages
- ✅ **Code Reuse:** Có thể share business logic với Web (Dart → JS)

**When to Build Flutter App:**
- Sau khi Web có 500+ active users
- Khi cần features chỉ mobile có (background MIDI recording, better offline)
- Khi users yêu cầu native app experience

**Flutter Dependencies (Future):**
```yaml
dependencies:
  flutter_webrtc: ^0.9.0         # Video Call
  flutter_midi_command: ^0.4.0   # MIDI
  socket_io_client: ^2.0.0       # WebSocket
  flutter_secure_storage: ^9.0.0 # Secure tokens
  cached_network_image: ^3.3.0   # Image caching
  google_maps_flutter: ^2.5.0    # Maps
  in_app_purchase: ^3.1.0        # Payments
```

**Web vs Mobile Feature Comparison:**
| Framework | Pros | Cons | Timeline |
| **Next.js (Web)** | Fast to market, SEO, No app store | Limited offline, No background tasks | ✅ **Phase 1 MVP** |
| **Flutter** | Native performance, Beautiful UI, Hot reload | Need to learn Dart, Bigger app size | ✅ **Phase 2 Mobile** |
| React Native | Large ecosystem, JavaScript | Performance issues with MIDI | ⚠️ Backup option |
| Native (Swift/Kotlin) | Best performance | 2x development cost | ❌ Too expensive |

---

### 4.2 Backend (API + Services)

#### Recommended: **Node.js + NestJS** (Main) + **Python** (AI Services)

#### 4.2.1 Main Backend - **NestJS** (TypeScript)

**Why NestJS?**
- ✅ **Scalable Architecture:** Modular design, microservice-ready
- ✅ **TypeScript:** Type safety, better maintainability
- ✅ **WebSocket Built-in:** Socket.IO integration cho MIDI
- ✅ **Dependency Injection:** Dễ test và scale
- ✅ **Fast Development:** CLI scaffolding, decorators

**Project Structure:**
```
backend/
├── apps/
│   ├── api/                    # Main REST API (Port 3000)
│   │   ├── auth/
│   │   ├── users/
│   │   ├── bookings/
│   │   ├── payments/
│   │   └── notifications/
│   │
│   ├── realtime/               # WebSocket Server (Port 3001)
│   │   ├── midi/               # MIDI streaming
│   │   ├── video/              # WebRTC signaling
│   │   └── chat/
│   │
│   └── cron/                   # Background Jobs (Port 3002)
│       ├── reminders/
│       └── analytics/
│
├── libs/                       # Shared libraries
│   ├── common/
│   ├── database/
│   └── integrations/
│
└── package.json
```

**Core Dependencies:**
```json
{
  "dependencies": {
    "@nestjs/core": "^10.x",
    "@nestjs/websockets": "^10.x",
    "@nestjs/microservices": "^10.x",
    "@prisma/client": "^5.x",           // ORM
    "socket.io": "^4.x",
    "bull": "^4.x",                      // Job Queue
    "ioredis": "^5.x",                   // Redis client
    "@nestjs/passport": "^10.x",         // Auth
    "stripe": "^14.x",                   // Payment (international)
    "axios": "^1.x"
  }
}
```

---

#### 4.2.2 AI Services - **Python + FastAPI**

**Why Python?**
- ✅ **AI/ML Libraries:** Librosa, Magenta (Google), Pretty_midi cho MIDI analysis
- ✅ **Fast Inference:** TensorFlow/PyTorch cho model deployment
- ✅ **FastAPI:** Modern, async, tốc độ cao (tương đương Node.js)

**Use Cases:**
- MIDI Performance Analysis (timing, dynamics)
- Practice Session Scoring
- Recommendation Engine (suggest songs, teachers)
- Emotion Detection (future feature)

**Project Structure:**
```
ai-services/
├── api/
│   ├── main.py                # FastAPI entry
│   └── routes/
│       ├── analysis.py        # POST /analyze/midi
│       └── recommendations.py # GET /recommend/songs
│
├── models/
│   ├── midi_analyzer.py       # LSTM model for timing
│   └── song_recommender.py    # Collaborative filtering
│
├── workers/
│   └── celery_worker.py       # Async processing
│
└── requirements.txt
```

**Core Dependencies:**
```txt
fastapi==0.109.0
uvicorn[standard]==0.27.0
celery==5.3.0
redis==5.0.0
librosa==0.10.1              # Audio processing
pretty_midi==0.2.10          # MIDI manipulation
tensorflow==2.15.0           # ML models
scikit-learn==1.4.0
pandas==2.2.0
```

---

### 4.3 Database Layer

#### Primary Database: **PostgreSQL 16**

**Why PostgreSQL?**
- ✅ **Relational Integrity:** Bookings, Users, Payments cần ACID
- ✅ **JSONB Support:** Flexible cho MIDI event storage
- ✅ **Full-text Search:** Tìm kiếm giáo viên, bài hát
- ✅ **PostGIS Extension:** Geolocation queries (tìm kho đàn gần nhất)
- ✅ **Mature Ecosystem:** Prisma ORM, pgBouncer, TimescaleDB (time-series)

**Schema Design (Key Tables):**
```sql
-- Users (Multi-tenant)
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone VARCHAR(15) UNIQUE NOT NULL,
  email VARCHAR(255),
  full_name VARCHAR(255),
  role VARCHAR(20) CHECK (role IN ('student', 'teacher', 'partner')),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Pianos (Inventory)
CREATE TABLE pianos (
  id UUID PRIMARY KEY,
  partner_id UUID REFERENCES users(id),
  model VARCHAR(100),
  brand VARCHAR(50),
  daily_rate DECIMAL(10,2),
  status VARCHAR(20) DEFAULT 'available',
  location GEOGRAPHY(POINT, 4326), -- PostGIS
  specs JSONB
);

-- Bookings (E-commerce)
CREATE TABLE bookings (
  id UUID PRIMARY KEY,
  student_id UUID REFERENCES users(id),
  piano_id UUID REFERENCES pianos(id),
  start_date DATE,
  end_date DATE,
  total_price DECIMAL(10,2),
  status VARCHAR(20), -- pending, paid, active, returned
  created_at TIMESTAMP DEFAULT NOW()
);

-- Class Sessions (Learning)
CREATE TABLE class_sessions (
  id UUID PRIMARY KEY,
  student_id UUID REFERENCES users(id),
  teacher_id UUID REFERENCES users(id),
  scheduled_at TIMESTAMP,
  duration_minutes INTEGER,
  status VARCHAR(20),
  midi_log_file VARCHAR(255), -- S3 URL
  video_recording VARCHAR(255)
);

-- MIDI Events (Time-series - Use TimescaleDB)
CREATE TABLE midi_events (
  id BIGSERIAL,
  session_id UUID REFERENCES class_sessions(id),
  user_id UUID,
  timestamp TIMESTAMP NOT NULL,
  command VARCHAR(20),
  note INTEGER,
  velocity INTEGER,
  PRIMARY KEY (id, timestamp)
);

SELECT create_hypertable('midi_events', 'timestamp');
```

---

#### Cache Layer: **Redis 7**

**Use Cases:**
- Session storage (JWT tokens)
- Real-time room state (WebSocket connections)
- Rate limiting (API throttling)
- Leaderboard (Sorted Sets)
- Job Queue (Bull/BullMQ)

**Data Structures:**
```redis
# Active WebSocket Rooms
HSET room:CS_001 student_123 "connected"
HSET room:CS_001 teacher_456 "connected"

# MIDI Event Buffer (Last 100 events per session)
LPUSH session:CS_001:midi "{note:60, velocity:80, ts:123456}"
LTRIM session:CS_001:midi 0 99

# User Session
SET session:user_123 "jwt_token" EX 86400

# Leaderboard
ZADD leaderboard:weekly 1250 user_123
```

---

#### Log Storage: **MongoDB** (Optional)

**Use Cases:**
- Application logs (Winston → MongoDB)
- Audit logs (User actions)
- Analytics events (Mixpanel-like)

**Alternative:** Elasticsearch + Kibana (if need advanced search)

---

#### File Storage: **AWS S3** / **DigitalOcean Spaces**

**Use Cases:**
- User avatars
- Piano images
- Lesson video recordings (HLS format)
- MIDI log files (.mid)
- Practice reports (PDF)

**Storage Strategy:**
```
s3://xpiano-production/
  ├── avatars/
  │   └── {user_id}.jpg
  ├── pianos/
  │   └── {piano_id}/
  │       ├── image-1.jpg
  │       └── image-2.jpg
  ├── lessons/
  │   └── {session_id}/
  │       ├── recording.m3u8 (HLS)
  │       ├── midi-log.mid
  │       └── report.pdf
  └── uploads/
      └── temp/
```

**CDN:** Cloudflare (Free tier) cho static assets

---

### 4.4 Real-time Communication

#### Video Call: **WebRTC** (P2P) + **Mediasoup** (SFU)

**Why WebRTC?**
- ✅ **Low Latency:** < 150ms cho video/audio
- ✅ **Browser Native:** Không cần plugin
- ✅ **P2P:** Tiết kiệm bandwidth server

**Architecture:**

**Phase 1 (MVP) - P2P:**
```
Student ←──WebRTC (Direct)──→ Teacher
           ↑
           │
      NestJS Server (Signaling only)
      - Exchange SDP Offer/Answer
      - ICE Candidate exchange
```

**Phase 2 (Scale) - SFU (Selective Forwarding Unit):**
```
Student ──→ Mediasoup Server ──→ Teacher
                 ↓
           (Forwards streams without decoding)
           (Supports 10+ participants for group class)
```

**Mediasoup vs Alternatives:**
| Solution | Pros | Cons | Verdict |
|----------|------|------|---------|
| **Mediasoup** | Open-source, Low latency, Self-hosted | Complex setup | ✅ Recommended for scale |
| Agora.io | Easy integration, Managed | Expensive ($1.99/1000 mins) | ❌ Too costly |
| Twilio Video | Reliable, Good docs | Very expensive | ❌ |
| Jitsi | Free, Open-source | Higher latency | ⚠️ Backup option |

**Implementation:**
```typescript
// React Native - Student Side
import { RTCPeerConnection, mediaDevices } from 'react-native-webrtc';

const peerConnection = new RTCPeerConnection({
  iceServers: [
    { urls: 'stun:stun.l.google.com:19302' },
    { urls: 'turn:turn.xpiano.vn:3478', username: 'xxx', credential: 'yyy' }
  ]
});

// Get local stream (camera + mic)
const localStream = await mediaDevices.getUserMedia({
  video: true,
  audio: { echoCancellation: true, noiseSuppression: true }
});

// Create offer
const offer = await peerConnection.createOffer();
await peerConnection.setLocalDescription(offer);

// Send offer to teacher via WebSocket
socket.emit('call:offer', { sessionId, offer });
```

---

#### MIDI Streaming: **WebSocket** (Socket.IO)

**Why WebSocket?**
- ✅ **Full Duplex:** Bidirectional real-time
- ✅ **Low Overhead:** Nhỏ hơn HTTP polling
- ✅ **Event-based:** Dễ handle nhiều event types

**Message Flow:**
```
Student Device (MIDI Input)
    ↓
React Native MIDI Module (Native)
    ↓ (Parse MIDI bytes)
WebSocket Client (Socket.IO)
    ↓ (Emit event)
NestJS WebSocket Gateway
    ↓ (Broadcast to room)
Teacher App (Display) + Redis (Buffer) + AI Service (Analysis Queue)
```

**Latency Optimization:**
- Use Binary Protocol (MessagePack thay vì JSON)
- Batch events (Send mỗi 16ms = 60fps)
- Compress data (LZ4 compression)

**Expected Latency:**
- LAN: 10-20ms
- 4G: 30-50ms
- 3G: 80-150ms

**Code Example:**
```typescript
// NestJS - MIDI Gateway
@WebSocketGateway({ namespace: '/midi' })
export class MidiGateway {
  @SubscribeMessage('midi:event')
  handleMidiEvent(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: MidiEventDto
  ) {
    // Broadcast to room (teacher + AI service)
    client.to(data.sessionId).emit('midi:event', data);
    
    // Buffer to Redis (last 100 events)
    this.redisService.lpush(
      `session:${data.sessionId}:midi`,
      JSON.stringify(data)
    );
    
    // Async send to AI analysis (via Bull Queue)
    this.midiAnalysisQueue.add('analyze', data);
  }
}
```

---

### 4.5 DevOps & Infrastructure

#### Hosting: **DigitalOcean** (Phase 1) → **AWS** (Phase 2)

**Why DigitalOcean for MVP?**
- ✅ **Cost-effective:** $12/month VPS vs AWS $50+
- ✅ **Simple Setup:** 1-click deploy, managed DB
- ✅ **Vietnam DC:** SGP1 datacenter (low latency to VN)

**MVP Setup:**
```
┌──────────────────────────────────────────────┐
│  DigitalOcean Droplet (4GB RAM, 2 vCPU)     │
│  - Docker Compose                            │
│  - NestJS API (Port 3000)                    │
│  - NestJS WebSocket (Port 3001)              │
│  - Redis (Port 6379)                         │
│  - Nginx (Reverse Proxy)                     │
└──────────────────────────────────────────────┘
         │
         ↓
┌──────────────────────────────────────────────┐
│  DigitalOcean Managed PostgreSQL             │
│  - 1GB RAM, 10GB Storage                     │
└──────────────────────────────────────────────┘
         │
         ↓
┌──────────────────────────────────────────────┐
│  DigitalOcean Spaces (S3-compatible)         │
│  - 250GB Storage, 1TB Bandwidth              │
└──────────────────────────────────────────────┘
```

**Total Cost (MVP):** ~$50/month

---

**Scale-up Plan (AWS):**
```
┌────────────────────────────────────────────────────────┐
│  CloudFront CDN                                        │
└────────────────────┬───────────────────────────────────┘
                     │
┌────────────────────┴───────────────────────────────────┐
│  Application Load Balancer                             │
└────────────────────┬───────────────────────────────────┘
                     │
    ┌────────────────┼────────────────┐
    │                │                │
┌───┴────┐      ┌───┴────┐      ┌───┴────┐
│ ECS    │      │ ECS    │      │ ECS    │
│ API    │      │ API    │      │ API    │
│ (×3)   │      │ (×3)   │      │ (×3)   │
└────────┘      └────────┘      └────────┘
                     │
    ┌────────────────┼────────────────┐
    │                │                │
┌───┴──────┐   ┌─────┴─────┐   ┌─────┴──────┐
│ RDS      │   │ ElastiCache│   │  S3 +      │
│Postgres  │   │   Redis    │   │ CloudFront │
│(Multi-AZ)│   │  (Cluster) │   │            │
└──────────┘   └────────────┘   └────────────┘
```

---

#### CI/CD: **GitHub Actions**

**Pipeline:**
```yaml
name: Deploy Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm test
      - run: npm run test:e2e

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - run: docker build -t xpiano/api .
      - run: docker push xpiano/api:${{ github.sha }}

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: appleboy/ssh-action@master
        with:
          host: ${{ secrets.DO_HOST }}
          script: |
            docker pull xpiano/api:${{ github.sha }}
            docker-compose up -d --no-deps api
```

---

#### Monitoring: **Sentry** + **Grafana** + **Uptime Robot**

| Tool | Purpose | Cost |
|------|---------|------|
| **Sentry** | Error tracking (App + Backend) | Free tier (5k errors/month) |
| **Grafana + Prometheus** | Metrics (CPU, Memory, Latency) | Self-hosted (Free) |
| **Uptime Robot** | Uptime monitoring (ping API every 5 mins) | Free (50 monitors) |
| **LogRocket** (Optional) | User session replay | $99/month (Scale phase) |

---

### 4.6 Tech Stack Summary Table

| Layer | Technology | Justification | Alternatives |
|-------|-----------|---------------|--------------|
| **Web (Phase 1)** | Next.js 14 + PWA | SSR, SEO, Fast deploy, Free hosting | React SPA, Vue/Nuxt |
| **Mobile (Phase 2)** | Flutter | Native performance, Beautiful UI, Cross-platform | React Native, Native |
| **Backend API** | Node.js + NestJS | Scalable, TypeScript, WebSocket support | Express, Fastify |
| **AI Services** | Python + FastAPI | ML libraries, Fast inference | Node.js (TensorFlow.js) |
| **Database** | PostgreSQL 16 | ACID, JSONB, PostGIS | MySQL, MongoDB |
| **Cache** | Redis 7 | In-memory, Pub/Sub, Job queue | Memcached |
| **File Storage** | S3 / DO Spaces | Scalable, CDN-ready | Self-hosted MinIO |
| **Video Call** | WebRTC + Mediasoup | Low latency, P2P, Self-hosted | Agora, Twilio |
| **MIDI Streaming** | WebSocket (Socket.IO) | Full-duplex, Event-based | gRPC, MQTT |
| **Payment** | VNPay + Momo SDK | Vietnam support, Low fee | Stripe (international) |
| **Hosting (MVP)** | DigitalOcean | Cost-effective, Simple | AWS, GCP |
| **Hosting (Scale)** | AWS (ECS + RDS) | Auto-scaling, Global reach | DigitalOcean, Azure |
| **CI/CD** | GitHub Actions | Free, Integrated | GitLab CI, Jenkins |
| **Monitoring** | Sentry + Grafana | Error tracking + Metrics | New Relic, Datadog |

---

## 5. CHIẾN LƯỢC PHÁT TRIỂN (DEVELOPMENT ROADMAP)

### 5.1 Phase 1 - Web MVP (Progressive Web App)
**Timeline:** 2-3 tháng  
**Platform:** Next.js 14 + PWA  
**Goal:** Validate business model với 100-200 users

**Why Web First:**
- ⚡ **Launch in days, not months:** Deploy Vercel trong 5 phút
- 📱 **Mobile-responsive:** 90% users dùng phone browser vẫn OK
- 🔗 **Zero friction:** Share link → test ngay, không cần install
- 💰 **Cost-effective:** 1 fullstack dev thay vì team mobile + backend
- 🧪 **Fast iteration:** Update code → live trong 2 phút
- 🔍 **SEO:** Google index → organic traffic miễn phí

#### 5.1.1 Core Features (Web MVP - Must Have)

**1. User Management (Week 1-2)**
- [ ] Auth: OTP login (SMS via Viettel)
- [ ] Profile: Basic info (name, age, role)
- [ ] Onboarding: 3-screen tutorial
- [ ] Role selection: Student / Teacher / Partner

**2. Piano Rental Marketplace (Week 3-5)**
- [ ] Piano Listing:
  - Browse pianos (list view)
  - Filter by location (PostGIS radius search)
  - Piano detail page (photos, specs, reviews)
- [ ] Booking Flow:
  - Select rental duration (1/3/6 months)
  - Choose delivery date
  - Enter address (Google Maps integration)
  - Add insurance/accessories
- [ ] Payment:
  - VNPay integration
  - Momo integration
  - Order confirmation page
- [ ] Partner Portal (Web):
  - View new orders
  - Confirm/reject bookings
  - Update piano inventory
  - Mark as shipped

**3. MIDI Connection (Week 6-7)**
- [ ] Device Pairing:
  - Auto-detect USB MIDI device
  - Connection tutorial (video)
  - Test connection (play a note)
- [ ] MIDI Input:
  - Receive MIDI events from piano
  - Display piano keys on screen
  - Log events to backend

**4. Teacher Marketplace (Week 8-9)**
- [ ] Teacher Listing:
  - Browse teachers (avatar, rating, hourly rate)
  - Filter by availability
  - Teacher profile page (bio, video intro)
- [ ] Booking:
  - Calendar view (available slots)
  - Book 1-hour lesson
  - Payment (same as piano rental)
- [ ] Teacher App:
  - View upcoming lessons
  - Accept/decline bookings
  - Manage availability calendar

**5. Live Online Class (Week 10-12)**
- [ ] Video Call:
  - WebRTC P2P connection
  - Camera + Mic controls
  - Teacher/Student video layout
- [ ] MIDI Streaming:
  - Real-time MIDI from student → teacher
  - Display student's piano input on teacher screen
  - Latency < 100ms (4G)
- [ ] Basic Teaching Tools:
  - Text chat
  - Screen sharing (teacher only)
  - End class button

**6. Post-Class Flow (Week 13)**
- [ ] Rating & Review:
  - Rate teacher (1-5 stars)
  - Leave review text
- [ ] Practice Assignment:
  - Teacher assigns homework (text)
  - Student sees in "Practice" tab
- [ ] Payment Release:
  - Auto-release to teacher after class ends

---

#### 5.1.2 Web MVP Tech Stack

**Frontend (Next.js):**
```
xpiano-web/
├── app/
│   ├── (auth)/
│   │   ├── login/
│   │   └── signup/
│   ├── (student)/
│   │   ├── pianos/          # Browse & rent
│   │   ├── teachers/        # Book lessons
│   │   ├── practice/        # MIDI practice
│   │   └── classroom/       # Live lesson
│   ├── (teacher)/
│   │   └── dashboard/
│   ├── (partner)/
│   │   └── portal/
│   └── api/                 # API routes
│       ├── auth/
│       ├── bookings/
│       └── webhooks/
├── components/
│   ├── ui/                  # shadcn components
│   ├── piano-keyboard.tsx   # Virtual piano
│   ├── video-call.tsx       # WebRTC component
│   └── midi-visualizer.tsx
├── lib/
│   ├── db.ts               # Prisma client
│   ├── auth.ts             # NextAuth
│   └── midi.ts             # Web MIDI API
└── public/
    └── manifest.json       # PWA config
```

**Trade-offs for Speed:**
- ✅ Web MIDI API (Chrome/Edge only, ~70% users)
- ❌ No iOS Safari MIDI (need workaround or wait for app)
- ❌ No background MIDI recording (browser limitation)
- ❌ No AI analysis in MVP (manual feedback only)
- ❌ No group classes (1-on-1 only)
- ❌ No social features (focus on core loop)

**Infrastructure (All Free/Cheap):**
- **Hosting:** Vercel (Free tier → $20/month Pro)
- **Database:** Supabase Free tier (500MB, 2GB bandwidth) hoặc Railway ($5/month)
- **Storage:** Cloudflare R2 ($0.015/GB, free egress)
- **Redis:** Upstash Free tier (10k requests/day)
- **Monitoring:** Sentry Free (5k events/month)

**Team Size (Reduced!):**
- 1 Fullstack Dev (Next.js + NestJS) → Có thể dùng Next.js API routes luôn
- 1 Designer (UI/UX)
- Part-time QA

**Total Cost:**
- Dev: ~$9k (3 months × $3k/month)
- Infrastructure: **$0-50** (mostly free tier)
- **Total: ~$9k** (save 40% vs mobile-first)

---

#### 5.1.3 When to Build Flutter App (Phase 2)

**Triggers to Start Mobile Development:**
- ✅ 200+ active users on web
- ✅ 40%+ D7 retention
- ✅ Product-market fit validated
- ✅ Users request native app (better offline, notifications)
- ✅ Need iOS support (Safari no MIDI)

**Flutter Development Timeline:** 2-3 months
**Cost:** +$8k (reuse backend, only rebuild UI)

---

#### 5.1.3 Success Metrics (MVP)

**Acquisition:**
- 100 students sign up
- 20 teachers onboard
- 5 partner stores

**Activation:**
- 60% students rent a piano
- 40% students book a lesson

**Retention:**
- 30% students book 2nd lesson
- 20% D7 retention

**Revenue:**
- $5k GMV (Gross Merchandise Value)
- 20% platform take rate → $1k revenue

**Technical:**
- 99% uptime
- < 100ms MIDI latency (P95)
- < 5% crash rate

---

### 5.2 Phase 2 - Mobile App + Growth
**Timeline:** 4-6 tháng (sau Web MVP)  
**Platform:** Flutter (iOS + Android) + Web improvements  
**Goal:** Scale to 1,000 users + Native app experience

#### 5.2.1 Flutter App Development (Month 4-5)

**Core Features to Port:**
- [ ] Rewrite UI in Flutter (Material Design)
- [ ] Native MIDI support (flutter_midi_command)
- [ ] Better WebRTC performance
- [ ] Offline mode (Hive/Drift database)
- [ ] Background MIDI recording
- [ ] Native push notifications
- [ ] Biometric login (fingerprint/face ID)
- [ ] App Store + Google Play submission

**Code Reuse Strategy:**
- Backend API unchanged (same NestJS server)
- UI rebuild in Flutter (~60% effort)
- Business logic can port from TypeScript → Dart
- Design system reuse (same colors, fonts)

**Flutter Project Structure:**
```
xpiano_app/
├── lib/
│   ├── features/
│   │   ├── auth/
│   │   ├── piano_rental/
│   │   ├── classroom/
│   │   └── practice/
│   ├── core/
│   │   ├── api/          # HTTP client
│   │   ├── midi/         # MIDI handler
│   │   └── webrtc/       # Video call
│   ├── shared/
│   │   ├── widgets/
│   │   └── utils/
│   └── main.dart
├── android/
├── ios/
└── pubspec.yaml
```

---

#### 5.2.2 AI-Powered Features (Month 5-6)
- [ ] Real-time MIDI Analysis:
  - Timing accuracy score
  - Note correctness detection
  - Dynamics feedback (velocity)
- [ ] Practice Report:
  - Auto-generate PDF after class
  - Progress chart (accuracy over time)
  - Personalized suggestions
- [ ] Smart Recommendation:
  - Recommend songs based on skill level
  - Suggest teachers based on learning style

**2. Content Library (Month 6-7)**
- [ ] Song Library:
  - 100+ popular songs (Vietnamese + International)
  - Sheet music (PDF)
  - Reference MIDI files
  - Difficulty tags (Beginner/Intermediate/Advanced)
- [ ] Video Tutorials:
  - Pre-recorded lessons (async learning)
  - Watch → Practice → Submit recording
- [ ] Practice Mode:
  - Loop sections
  - Slow down tempo
  - Metronome

**3. Enhanced Teacher Tools (Month 7)**
- [ ] Lesson Planning:
  - Create lesson templates
  - Attach resources (PDFs, videos)
- [ ] Advanced Annotations:
  - Draw on sheet music (whiteboard)
  - Highlight specific measures
  - Record voice annotations
- [ ] Student Dashboard:
  - View all students
  - Track progress (attendance, practice hours)
  - Send reminders

**4. Gamification & Social (Month 8)**
- [ ] XP System:
  - Earn XP for practicing, completing lessons
  - Level up (Beginner → Intermediate → Advanced)
- [ ] Achievements:
  - "First Lesson", "7-Day Streak", "Perfect Score"
- [ ] Leaderboard:
  - Weekly/Monthly practice time ranking
  - Compare with friends
- [ ] Social Feed (Lite):
  - Share practice recordings
  - Like & comment
  - Follow teachers

**5. Operations & Trust (Month 8)**
- [ ] Logistics Dashboard:
  - Track all deliveries in real-time
  - Auto-dispatch to shipper (API integration)
- [ ] Dispute Resolution:
  - Report damaged piano
  - Request refund
  - Admin panel for CS team
- [ ] Insurance Claims:
  - Photo upload
  - Claim review workflow
- [ ] Verification:
  - Teacher background check
  - Partner store verification (business license)

---

#### 5.2.2 Infrastructure Upgrades

**Migrate to AWS:**
- ECS Fargate (auto-scaling containers)
- RDS Multi-AZ (high availability)
- ElastiCache Redis Cluster
- S3 + CloudFront CDN
- Load Balancer (ALB)

**Monitoring:**
- Grafana dashboards
- Sentry error tracking
- LogRocket session replay

**Cost:** ~$500/month

---

#### 5.2.3 Success Metrics (Growth)

**Acquisition:**
- 1,000 students
- 100 teachers
- 20 partners

**Activation:**
- 70% students rent piano
- 50% students book lesson

**Retention:**
- 40% D7 retention
- 50% students book 3+ lessons

**Revenue:**
- $50k GMV
- $10k revenue (20% take rate)

**Engagement:**
- 2.5 lessons/student/month
- 30 mins/day practice time

---

### 5.3 Phase 3 - Scale (Mở rộng)
**Timeline:** 9-12+ tháng  
**Goal:** National expansion + New revenue streams

#### 5.3.1 New Features

**1. Group Classes (Month 9)**
- [ ] 1-to-many teaching:
  - 5-10 students per class
  - Mediasoup SFU for video
  - Shared MIDI view (all students visible to teacher)
- [ ] Lower pricing: $10/student vs $25 for 1-on-1

**2. Multi-Instrument Support (Month 10)**
- [ ] Guitar:
  - MIDI Guitar pickup support
  - Chord detection
- [ ] Drums:
  - Electronic drum kit MIDI
- [ ] Violin:
  - MIDI violin (experimental)

**3. Enterprise Features (Month 11)**
- [ ] School Licenses:
  - Bulk student accounts
  - Teacher management portal
  - Custom branding
- [ ] Corporate Wellness:
  - Music lessons as employee benefit
  - Monthly subscription model

**4. Advanced AI (Month 12)**
- [ ] Emotion Detection:
  - Analyze MIDI dynamics to detect mood
  - Suggest songs matching emotion
- [ ] Auto-Accompaniment:
  - AI plays background chords
  - Student focuses on melody
- [ ] Composition Assistant:
  - Suggest next notes
  - Harmonization

**5. Marketplace Evolution (Month 12+)**
- [ ] Piano Sales (not just rental):
  - Used piano marketplace
  - Financing options (installments)
- [ ] Accessories Store:
  - Piano benches, lamps, sheet music
- [ ] Teacher Courses:
  - Teachers create & sell pre-recorded courses
  - Revenue share (70/30 split)

---

#### 5.3.2 Geographic Expansion

**Phase 3A (Month 9-10): North Vietnam**
- Hanoi (existing)
- Haiphong
- Vinh

**Phase 3B (Month 11-12): Central Vietnam**
- Da Nang
- Hue
- Nha Trang

**Phase 3C (Month 13+): South Vietnam**
- Ho Chi Minh City (huge market)
- Can Tho
- Vung Tau

**Challenges:**
- Need local partner stores in each city
- Logistics: Partner with national shippers (Giao Hàng Nhanh, Viettel Post)

---

#### 5.3.3 Business Model Evolution

**Revenue Streams:**
1. **Piano Rental Commission:** 20% of rental fee (existing)
2. **Lesson Marketplace Fee:** 20% of lesson fee (existing)
3. **Premium Subscriptions:**
   - "Xpiano Pro" ($10/month):
     - Unlimited AI analysis
     - Download sheet music
     - Ad-free experience
     - Priority support
4. **Course Sales:** 30% commission on teacher courses
5. **Enterprise Licenses:** $500/month per school

**Projected Revenue (Month 12):**
- Piano Rentals: $20k/month
- Lessons: $30k/month
- Subscriptions: $5k/month (500 users × $10)
- Courses: $3k/month
- **Total: $58k/month revenue**

---

### 5.4 Roadmap Visual Summary

```
┌─────────────────────────────────────────────────────────────────────────┐
│                  XPIANO DEVELOPMENT ROADMAP (WEB-FIRST)                 │
└─────────────────────────────────────────────────────────────────────────┘

Month:  1   2   3   4   5   6   7   8   9   10  11  12  13+
        │───────│───────│───────────│─────────────────│──────────>
        │       │       │           │                 │
Phase:  │ WEB   │FLUTTER│  GROWTH   │      SCALE      │  OPTIMIZE
        │  MVP  │  APP  │           │                 │
Users:  │  200  │  500  │   2,000   │     8,000       │  30,000+
        │       │       │           │                 │
        
Features Timeline:
───────────────────────────────────────────────────────────────────

Web MVP (Month 1-3):
├─ Next.js Setup              ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░
├─ Auth & Onboarding          ░██░░░░░░░░░░░░░░░░░░░░░░░░░░░
├─ Piano Rental (E-commerce)  ░░████░░░░░░░░░░░░░░░░░░░░░░░░
├─ Web MIDI Connection        ░░░░██░░░░░░░░░░░░░░░░░░░░░░░░
├─ Teacher Marketplace        ░░░░░███░░░░░░░░░░░░░░░░░░░░░░
├─ Live Video + MIDI (WebRTC) ░░░░░░░███░░░░░░░░░░░░░░░░░░░░
└─ PWA + Deploy Vercel        ░░░░░░░░░█░░░░░░░░░░░░░░░░░░░░

Flutter App (Month 4-5):
├─ Flutter Project Setup      ░░░░░░░░░░██░░░░░░░░░░░░░░░░░░
├─ UI Rebuild (Material)      ░░░░░░░░░░░███░░░░░░░░░░░░░░░░
├─ Native MIDI Integration    ░░░░░░░░░░░░░██░░░░░░░░░░░░░░░
├─ Offline Mode               ░░░░░░░░░░░░░░█░░░░░░░░░░░░░░░
└─ App Store Submission       ░░░░░░░░░░░░░░░█░░░░░░░░░░░░░░

Growth (Month 6-9):
├─ AI Analysis                ░░░░░░░░░░░░░░░░███░░░░░░░░░░░
├─ Content Library            ░░░░░░░░░░░░░░░░░░███░░░░░░░░░
├─ Gamification               ░░░░░░░░░░░░░░░░░░░░██░░░░░░░░
└─ Teacher Tools Enhanced     ░░░░░░░░░░░░░░░░░░░░░░██░░░░░░

Scale (Month 10-13+):
├─ Group Classes              ░░░░░░░░░░░░░░░░░░░░░░░░███░░░
├─ Multi-Instrument           ░░░░░░░░░░░░░░░░░░░░░░░░░░███░
├─ Enterprise Features        ░░░░░░░░░░░░░░░░░░░░░░░░░░░░███
└─ Geographic Expansion       ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██
```

---

### 5.5 Risk Mitigation & Contingency Plans

#### 5.5.1 Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| **MIDI latency > 200ms** | Medium | High | • Use binary protocol (MessagePack)<br>• Test on 3G/4G networks<br>• Add "Connection Quality" indicator |
| **WebRTC connection fails** | Medium | Critical | • Fallback to server-based video (Mediasoup)<br>• Pre-flight network test<br>• Show troubleshooting guide |
| **Database bottleneck** | Low | Medium | • Add read replicas (PostgreSQL)<br>• Cache frequently accessed data (Redis)<br>• Optimize queries |
| **Video storage costs** | High | Medium | • Don't record by default (opt-in only)<br>• Auto-delete after 30 days<br>• Compress with H.264 |

---

#### 5.5.2 Business Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| **Low teacher supply** | Medium | High | • Aggressive teacher acquisition campaign<br>• Higher commission for first 3 months<br>• Referral bonuses |
| **Piano damage/loss** | Medium | Medium | • Mandatory insurance (included in price)<br>• Require ID verification + deposit<br>• Partner with insurance company |
| **Payment fraud** | Low | High | • Two-factor authentication for payments<br>• Fraud detection (unusual patterns)<br>• Manual review for high-value transactions |
| **Competitor copycat** | High | Low | • Focus on execution speed<br>• Build network effects (more teachers → more students)<br>• Patent MIDI teaching method (if possible) |

---

#### 5.5.3 Regulatory Risks

| Risk | Mitigation |
|------|------------|
| **E-commerce license** | Register with Ministry of Industry and Trade (Bộ Công Thương) |
| **Education license** | Operate as "technology platform", not "education institution" |
| **Tax compliance** | Work with local accountant, issue VAT invoices |
| **Data privacy (PDPA)** | Implement GDPR-like policies, get user consent, encrypt data |

---

## 6. RỦI RO VÀ GIẢI PHÁP (RISKS & SOLUTIONS)

### 6.1 Technology Risks

#### 6.1.1 Real-time Latency Issues

**Problem:** MIDI events hoặc video bị delay, ảnh hưởng trải nghiệm học.

**Solutions:**
1. **Network Optimization:**
   - Adaptive bitrate for video (lower quality if network bad)
   - MIDI priority over video (send MIDI first)
   - Use UDP for MIDI (if TCP too slow)

2. **Infrastructure:**
   - Deploy servers in Singapore (closest to Vietnam)
   - Use CDN edge locations
   - P2P WebRTC (bypass server)

3. **Monitoring:**
   - Real-time latency dashboard (Grafana)
   - Alert if latency > 200ms (P95)
   - Auto-suggest "Switch to 3G-friendly mode"

---

#### 6.1.2 MIDI Device Compatibility

**Problem:** Một số đàn cũ không có MIDI USB, hoặc driver không tương thích.

**Solutions:**
1. **Hardware Requirements:**
   - Chỉ cho thuê đàn có MIDI USB (standardize inventory)
   - Provide MIDI-to-Bluetooth adapter (if needed)

2. **Software:**
   - Support Web MIDI API (Chrome browser fallback)
   - Driver installation guide (PDF + video)

3. **Customer Support:**
   - Live chat with tech support
   - Video call troubleshooting (TeamViewer)

---

### 6.2 Business Risks

#### 6.2.1 Supply-Side (Teacher/Partner) Acquisition

**Problem:** Khó thuyết phục giáo viên/kho đàn tham gia nền tảng mới.

**Solutions:**
1. **Incentives:**
   - 0% commission for first 3 months
   - Guaranteed minimum income ($500/month for first 10 teachers)
   - Marketing support (featured profile, ads)

2. **Value Proposition:**
   - Free teaching tools (better than Zoom)
   - Auto-matching students (no need to find students)
   - Flexible schedule

3. **Partnerships:**
   - Partner with music schools (recruit teachers)
   - Partner with piano stores (use as pickup locations)

---

#### 6.2.2 Demand-Side (Student) Retention

**Problem:** Học viên bỏ học sau 1-2 buổi (churn rate cao).

**Solutions:**
1. **Engagement Loops:**
   - Daily practice reminders (push notifications)
   - Streak gamification (7-day streak → reward)
   - Social proof (show friends' progress)

2. **Quality Control:**
   - Teacher rating system (remove low-rated teachers)
   - First lesson free (reduce risk)
   - Money-back guarantee (if not satisfied)

3. **Personalization:**
   - AI recommend songs based on taste
   - Match students with compatible teachers (personality test)

---

### 6.3 Operational Risks

#### 6.3.1 Logistics Challenges

**Problem:** Đàn bị hỏng trong quá trình vận chuyển, hoặc giao hàng chậm.

**Solutions:**
1. **Partner with Professional Shippers:**
   - Use specialized music instrument shipping (fragile handling)
   - Insurance included (up to piano value)
   - Track in real-time (GPS)

2. **Quality Checks:**
   - Partner inspects piano before shipping
   - Student confirms condition upon receipt (photos)
   - 24-hour return policy

3. **Backup Plans:**
   - Keep buffer inventory (5% extra pianos)
   - Same-day replacement if damage occurs

---

## 7. NEXT STEPS (Bước Tiếp Theo)

### 7.1 Immediate Actions (This Week) - Web MVP

**1. Development Setup (Day 1):**
```bash
# Initialize Next.js project
npx create-next-app@latest xpiano-web --typescript --tailwind --app

# Install core dependencies
cd xpiano-web
npm install @prisma/client @tanstack/react-query zustand
npm install socket.io-client webmidi framer-motion
npm install @shadcn/ui # UI components

# Setup database
npx prisma init
# Configure DATABASE_URL in .env

# Setup auth (NextAuth)
npm install next-auth
```

**2. Free Infrastructure Setup (Day 1):**
- [ ] GitHub account + create repo `xpiano/web`
- [ ] Vercel account (link với GitHub) - Deploy tự động
- [ ] Supabase account (PostgreSQL free) hoặc Railway
- [ ] Upstash account (Redis free tier)
- [ ] Cloudflare account (R2 storage)
- [ ] Domain: xpiano.vn (Tên Miền Việt Nam ~200k/năm)

**3. Team Formation (Week 1):**
- [ ] Hire 1 Fullstack Developer (Next.js + TypeScript)
   - Skills: React, Node.js, PostgreSQL, WebRTC, Web MIDI
   - Salary: $800-1,200/month (VN market)
- [ ] Hire UI/UX Designer (part-time)
   - Figma wireframes + design system
   - Salary: $400-600/month

**4. Design (Week 1-2):**
- [ ] Wireframe 5 core screens (Figma):
   - Landing page
   - Piano browsing
   - Booking flow
   - Live classroom
   - Teacher profile
- [ ] Design System:
   - Colors: Primary (Piano black), Accent (Music note blue)
   - Fonts: Inter (body), Poppins (headings)
   - Components library (shadcn/ui base)

**5. Legal (Can do later, not blocking MVP):**
- [ ] Register business (Công ty TNHH Xpiano) - ~$100
- [ ] Draft Terms of Service + Privacy Policy (use templates)
- [ ] ĐKKD Sàn TMĐT (if doing e-commerce officially)

---

### 7.2 Month 1 Milestones (Web MVP)

**Week 1-2: Foundation**
- [ ] Next.js project initialized
- [ ] Database schema designed (Prisma)
- [ ] Auth flow (OTP login with NextAuth)
- [ ] Landing page + Sign up flow
- [ ] Deployed to Vercel (staging)

**Week 3-4: Core Features**
- [ ] Piano listing page (fetch from DB)
- [ ] Piano detail page + booking form
- [ ] Payment integration (VNPay sandbox)
- [ ] Partner portal (basic dashboard)
- [ ] Web MIDI connection test (Chrome only)

**End of Month:**
- [ ] 5 pianos listed in system
- [ ] 1 partner store onboarded
- [ ] 3 test bookings completed
- [ ] Web MIDI working on 1 test piano
- [ ] Landing page live at xpiano.vn

---

### 7.3 Pre-Launch Checklist (Month 3)

- [ ] Beta testing with 10 students
- [ ] Load testing (100 concurrent users)
- [ ] Security audit (penetration testing)
- [ ] Payment integration tested (VNPay/Momo sandbox)
- [ ] Customer support SOP documented
- [ ] Marketing landing page live
- [ ] Press kit prepared (for PR)

---

## 8. PHỤ LỤC (APPENDIX)

### 8.1 Glossary (Thuật ngữ)

| Term | Definition |
|------|------------|
| **MIDI** | Musical Instrument Digital Interface - Chuẩn giao tiếp số cho nhạc cụ điện tử |
| **WebRTC** | Web Real-Time Communication - Công nghệ video call trên browser/app |
| **SFU** | Selective Forwarding Unit - Server chuyển tiếp video streams |
| **ORM** | Object-Relational Mapping - Thư viện map database → code objects |
| **CDC** | Change Data Capture - Đồng bộ database changes real-time |
| **GMV** | Gross Merchandise Value - Tổng giá trị giao dịch trên nền tảng |

---

### 8.2 References (Tài liệu tham khảo)

1. **MIDI Protocol:**
   - [MIDI 1.0 Specification](https://www.midi.org/specifications)
   - [Web MIDI API](https://webaudio.github.io/web-midi-api/)

2. **WebRTC:**
   - [WebRTC for the Curious](https://webrtcforthecurious.com/)
   - [Mediasoup Documentation](https://mediasoup.org/documentation/v3/)

3. **React Native:**
   - [React Native WebRTC](https://github.com/react-native-webrtc/react-native-webrtc)
   - [React Native MIDI (Custom)](https://github.com/example/rn-midi)

4. **NestJS:**
   - [NestJS WebSockets](https://docs.nestjs.com/websockets/gateways)
   - [Microservices Architecture](https://docs.nestjs.com/microservices/basics)

5. **Market Research:**
   - Vietnam E-learning Market Report 2025
   - Sharing Economy in Southeast Asia (McKinsey)

---

### 8.3 Contact & Support

**Project Owner:**
- Email: founder@xpiano.vn
- Phone: +84 XXX XXX XXX

**Technical Lead:**
- Email: tech@xpiano.vn
- Slack: #xpiano-dev

**Documentation:**
- GitHub Wiki: https://github.com/xpiano/docs
- Notion Workspace: https://notion.so/xpiano

---

## 📌 TÓM TẮT CHO ĐỘI DEV

### Development Strategy: WEB-FIRST 🌐 → FLUTTER 📱

**Phase 1 (Month 1-3): Web MVP**
- Platform: Next.js 14 + PWA
- Target: Desktop + Mobile browser
- Users: 200 early adopters
- Cost: ~$9k total

**Phase 2 (Month 4-5): Flutter App**
- Platform: iOS + Android native
- Reuse: Backend API unchanged
- Target: 1,000+ users
- Cost: +$8k

### Core Technical Challenges:
1. **Web MIDI API:** Only Chrome/Edge support (70% users) → Need Safari workaround
2. **Low-latency streaming:** WebSocket + Binary protocol
3. **Real-time video + MIDI sync:** WebRTC P2P
4. **PWA limitations:** No background tasks, limited offline
5. **Scalable backend:** NestJS or Next.js API routes + PostgreSQL + Redis

### Web MVP Focus (2-3 months):
- Piano rental e-commerce ✅
- Web MIDI device pairing (Chrome) ✅
- 1-on-1 video lessons (WebRTC) ✅
- Teacher marketplace ✅
- Progressive Web App (installable) ✅

### Scale Strategy:
- Start with DigitalOcean ($50/month)
- Migrate to AWS when hit 1,000 users
- Add AI features in Phase 2
- Expand to multi-instrument in Phase 3

### Success Metrics:
- **MVP:** 100 users, $5k GMV, 30% retention
- **Growth:** 1,000 users, $50k GMV, 40% retention
- **Scale:** 5,000+ users, $200k GMV/month

---

**Version History:**
- v1.0 (Jan 31, 2026): Initial system overview
- Future updates will be tracked in this document

**Status:** ✅ Ready for development kickoff

---

*Document prepared by: Senior System Architect & Product Manager*  
*For: Xpiano Development Team*  
*Confidential - Internal Use Only*
