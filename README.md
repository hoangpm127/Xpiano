# 🎹 Xpiano - Vietnam's First Music Ecosystem Platform

**Nền tảng hệ sinh thái âm nhạc đầu tiên tại Việt Nam**

[![Flutter](https://img.shields.io/badge/Flutter-3.19.0-02569B?logo=flutter)](https://flutter.dev)
[![Express](https://img.shields.io/badge/Express-4.x-000000?logo=express)](https://expressjs.com)
[![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-47A248?logo=mongodb)](https://mongodb.com)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.x-3178C6?logo=typescript)](https://typescriptlang.org)

---

## 🎯 Vision

Xpiano giải quyết bài toán "phần cứng" trong giáo dục âm nhạc bằng mô hình **Sharing Economy**, kết nối 3 bên:

- 👨‍🎓 **Học viên**: Thuê đàn piano/keyboard ship tận nhà
- 👨‍🏫 **Giáo viên**: Dạy online qua video call + MIDI streaming real-time
- 🏢 **Kho đàn**: Cho thuê đàn nhàn rỗi, tối ưu doanh thu

---

## 📁 Project Structure

```
D:\Xpiano/
├── backend/              # Express + TypeScript + MongoDB
│   ├── src/
│   │   ├── modules/
│   │   │   ├── auth/
│   │   │   ├── orders/
│   │   │   ├── commission/
│   │   │   └── wallet/
│   │   └── app.module.ts
│   └── package.json
│
├── web/                  # React.js Web Application
│   ├── src/
│   │   ├── app/
│   │   ├── components/
│   │   └── pages/
│   └── package.json
│
├── mobile/               # Flutter iOS + Android App
│   ├── lib/
│   │   ├── core/
│   │   │   ├── services/
│   │   │   │   ├── midi_service.dart
│   │   │   │   └── webrtc_service.dart
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── rental/
│   │   │   └── classroom/
│   │   └── main.dart
│   └── pubspec.yaml
│
├── shared/               # Shared types & constants
│   ├── types/
│   └── constants/
│
├── database/             # Database schemas
│   └── schema.sql
│
└── docs/                 # Documentation
    ├── DEVELOPMENT_PLAN.md
    ├── TECH_STACK_COMPARISON.md
    └── API_DOCS.md
```

---

## 🛠️ Tech Stack

### Backend
- **Framework**: Express.js + TypeScript
- **Database**: MongoDB Atlas (FREE tier)
- **Cache**: Redis (Upstash)
- **Auth**: JWT + OTP (Twilio)
- **Payment**: VNPay / MoMo

### Web
- **Framework**: React.js (Vite)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **State**: Zustand / Redux
- **WebRTC**: PeerJS
- **Maps**: Google Maps

### Mobile
- **Framework**: Flutter 3.19.0
- **Language**: Dart
- **State**: Provider
- **Video Call**: flutter_webrtc (< 50ms latency)
- **MIDI**: flutter_midi_command (< 10ms latency)
- **Maps**: google_maps_flutter

---

## 🚀 Quick Start

### Prerequisites
```bash
# Node.js 18+
node --version

# Flutter 3.19.0
flutter --version

# MongoDB Atlas account (FREE)
```

### Backend Setup
```bash
cd backend
npm install
cp .env.example .env
npm run dev
```

### Web Setup
```bash
cd web
npm install
npm run dev
```

### Mobile Setup
```bash
cd mobile
flutter pub get
flutter run -d windows  # or ios/android
```

---

## ✨ Key Features

### 🎹 Real-time MIDI (< 10ms latency)
- Capture piano input via USB/Bluetooth
- Forward to teacher in real-time
- Visual feedback on virtual keyboard

### 📹 Video Call (< 200ms latency)
- HD video (720p)
- Low-latency audio (< 50ms)
- Echo cancellation + noise suppression

### 🛒 Piano Marketplace
- Browse pianos nearby (PostGIS / MongoDB geo queries)
- Filter by brand, price, distance
- Smart dispatch (auto-select nearest warehouse)

### 💰 Wallet & Commission
- F1, F2 affiliate tracking
- Auto commission calculation
- Withdrawal requests

---

## 📊 Development Timeline

### Phase 1: Foundation (Week 1-2)
- [x] Backend setup (Express + MongoDB)
- [x] Flutter project init
- [ ] Authentication (JWT + OTP)

### Phase 2: Core Features (Week 3-4)
- [ ] Piano marketplace (CRUD)
- [ ] Booking flow
- [ ] Smart dispatch service

### Phase 3: Advanced (Week 5-6)
- [ ] Live classroom (WebRTC + MIDI)
- [ ] Commission processor
- [ ] Wallet management

### Phase 4: Deploy (Week 7-8)
- [ ] Backend → Railway
- [ ] Web → Vercel
- [ ] Mobile → TestFlight + Play Console

---

## 🎨 Brand

**Colors:**
- Primary: `#6B46C1` (Purple)
- Secondary: `#9333EA` (Light Purple)
- Accent: `#FBBF24` (Gold)

**Logo:** 🎹 Xpiano

---

## 🤝 Team

- **Person 1**: Backend Engineer (Express + MongoDB)
- **Person 2**: Web Frontend Engineer (React.js)
- **Person 3**: Mobile Engineer (Flutter)

---

## 📚 Documentation

- [Development Plan](docs/DEVELOPMENT_PLAN.md)
- [Tech Stack Comparison](docs/TECH_STACK_COMPARISON.md)
- [Flutter Setup Guide](docs/FLUTTER_SETUP_GUIDE.md)
- [API Documentation](docs/API_DOCS.md) (TODO)

---

## 💰 Infrastructure Costs

### MVP (Month 1-3): **$10/month**
- MongoDB Atlas: FREE (512MB)
- Vercel: FREE
- Railway: $5/month
- Twilio SMS: FREE trial ($15 credit)

### Production (Month 4+): **$65/month**
- MongoDB Atlas M10: $57/month
- Railway: $5/month
- SMS: $20/month

---

## 🐛 Troubleshooting

### Flutter not found
```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";D:\flutter\flutter\bin", "User")
```

### MongoDB connection failed
Check `.env` connection string

### WebRTC not working
Enable camera/mic permissions

---

## 📝 License

Proprietary - Xpiano © 2026

---

## 📞 Contact

- **Email**: contact@xpiano.com
- **Website**: https://xpiano.com (TODO)
- **Support**: support@xpiano.com

---

**Made with ❤️ in Vietnam** 🇻🇳
