# 🎹 XPIANO - DEVELOPMENT PLAN
## 3-Person Team Roadmap (8 Weeks)

**Version:** 1.0  
**Date:** February 5, 2026  
**Team Size:** 3 Engineers + AI Agents  
**Target:** Launch Web + Mobile MVP  

---

## 📊 TEAM STRUCTURE

```
┌─────────────────────────────────────────────────────────────┐
│                    XPIANO TEAM                               │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  👤 PERSON 1: Backend Engineer                              │
│  ├─ NestJS + PostgreSQL + Redis                             │
│  ├─ API Development                                          │
│  └─ Infrastructure & DevOps                                  │
│                                                              │
│  👤 PERSON 2: Web Frontend Engineer                         │
│  ├─ Next.js + TypeScript                                     │
│  ├─ WebRTC + Web MIDI                                        │
│  └─ UI/UX Implementation                                     │
│                                                              │
│  👤 PERSON 3: Mobile Engineer                               │
│  ├─ Flutter (iOS + Android)                                  │
│  ├─ Flutter WebRTC + MIDI                                    │
│  └─ Native Features                                          │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 8-WEEK TIMELINE OVERVIEW

```
WEEK 1-2: FOUNDATION
█████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 25%
├─ Backend: Auth + Core APIs
├─ Web: Landing Page + Setup
└─ Mobile: Project Setup + UI Shells

WEEK 3-4: CORE FEATURES
░░░░░░░░░█████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 50%
├─ Backend: Business Logic (Orders, Warehouses)
├─ Web: Marketplace + Booking
└─ Mobile: Core Screens + API Integration

WEEK 5-6: ADVANCED FEATURES
░░░░░░░░░░░░░░░░░░█████████░░░░░░░░░░░░░░░░░░░░ 75%
├─ Backend: Commission + Wallet + WebSocket
├─ Web: Classroom (WebRTC + MIDI)
└─ Mobile: Video Call + MIDI + Wallet

WEEK 7-8: DEPLOY & LAUNCH
░░░░░░░░░░░░░░░░░░░░░░░░░░█████████░░░░░░░░░░░░ 100%
├─ Backend: Deploy + CI/CD
├─ Web: Deploy Vercel + SEO
└─ Mobile: TestFlight + Play Console Beta
```

---

## 👤 PERSON 1: BACKEND ENGINEER

### **WEEK 1-2: Foundation** ✅

#### **Day 1-2: Infrastructure Setup**
```bash
□ Setup PostgreSQL + PostGIS (Docker)
  docker-compose.yml:
    - postgres:16 with PostGIS
    - redis:7-alpine
    
□ Setup Redis for caching
□ Initialize NestJS project structure
□ Setup Prisma ORM
□ Configure environment variables (.env)
```

#### **Day 3-5: Authentication Module**
```typescript
backend/src/modules/auth/
├─ auth.module.ts
├─ auth.controller.ts
├─ auth.service.ts
├─ strategies/
│   ├─ jwt.strategy.ts
│   └─ local.strategy.ts
└─ guards/
    └─ jwt-auth.guard.ts

Features:
□ JWT authentication
□ OTP login (SMS via Twilio)
□ Refresh token mechanism
□ Login/Logout endpoints
```

#### **Day 6-10: Users Module**
```typescript
backend/src/modules/users/
├─ users.module.ts
├─ users.controller.ts
├─ users.service.ts
└─ dto/
    ├─ create-user.dto.ts
    └─ update-user.dto.ts

Features:
□ User CRUD operations
□ Profile management
□ Referral code generation (affiliate)
□ User search & filtering
```

**Output Week 1-2:**
- ✅ `/api/auth/login` - OTP login
- ✅ `/api/auth/verify-otp` - Verify OTP
- ✅ `/api/users/profile` - Get user profile
- ✅ Swagger docs at `/api/docs`

---

### **WEEK 3-4: Core Business Logic** ⚙️

#### **Day 11-15: Warehouses Module**
```typescript
backend/src/modules/warehouses/
├─ warehouses.module.ts
├─ warehouses.controller.ts
├─ warehouses.service.ts
└─ dto/

Features:
□ Warehouse CRUD
□ PostGIS integration (location queries)
□ Find nearest warehouse (ST_Distance)
□ Warehouse availability check
□ Partner dashboard data
```

**Key SQL Query:**
```sql
SELECT *, ST_Distance(
  location,
  ST_GeogFromText('POINT(105.8412 21.0245)')
) AS distance
FROM warehouses
WHERE is_active = true
ORDER BY distance
LIMIT 10;
```

#### **Day 16-20: Pianos Module**
```typescript
backend/src/modules/pianos/
├─ pianos.module.ts
├─ pianos.controller.ts
├─ pianos.service.ts
└─ dto/

Features:
□ Piano CRUD
□ Advanced search (brand, keys, price range)
□ Filtering & pagination
□ Availability calendar
□ Image upload (Cloudinary)
```

**Output Week 3-4:**
- ✅ `/api/warehouses?lat=21.0245&lng=105.8412` - Find nearby
- ✅ `/api/pianos?brand=Yamaha&minPrice=1000000` - Search
- ✅ `/api/pianos/:id/availability` - Check dates

---

### **WEEK 5-6: Advanced Features** 🚀

#### **Day 21-25: Orders & Smart Dispatch**
```typescript
backend/src/modules/orders/
├─ orders.module.ts
├─ orders.controller.ts
├─ orders.service.ts
├─ smart-dispatch.service.ts  // ✅ Already exists
└─ dto/

Features:
□ Order creation with smart dispatch
□ Order status tracking
□ Delivery scheduling
□ Order history
□ Cancel/Refund logic
```

#### **Day 26-30: Commission & Wallet**
```typescript
backend/src/modules/commission/
├─ commission.service.ts       // ✅ Already exists
└─ commission.processor.ts     // ✅ Already exists

backend/src/modules/wallet/
├─ wallet.service.ts           // ✅ Already exists
└─ wallet.controller.ts        // ✅ Already exists

Features:
□ Commission calculation (F1, F2)
□ Wallet transactions
□ Withdrawal requests
□ Transaction history
```

#### **Day 31-35: WebSocket Gateway**
```typescript
backend/src/gateways/
├─ classroom.gateway.ts
└─ chat.gateway.ts

Features:
□ Real-time messaging
□ Video call signaling (WebRTC)
□ Classroom events
□ Online status tracking
```

**Output Week 5-6:**
- ✅ `/api/orders` - Create order with auto warehouse selection
- ✅ `/api/wallet/transactions` - Transaction history
- ✅ `ws://api/classroom` - WebSocket connection

---

### **WEEK 7-8: Deploy & Optimize** 🚀

#### **Day 36-40: Testing & Documentation**
```bash
□ Unit tests (Jest) - 80% coverage
□ Integration tests
□ API Documentation (Swagger complete)
□ Postman collection export
□ README with setup instructions
```

#### **Day 41-45: Deployment**
```bash
□ Docker image build
□ Deploy to Railway/Render
□ Setup PostgreSQL production DB
□ Setup Redis production
□ Environment variables config
□ CI/CD pipeline (GitHub Actions)
```

#### **Day 46-50: Monitoring & Optimization**
```bash
□ Setup Sentry for error tracking
□ Database indexing optimization
□ API rate limiting
□ Caching strategy (Redis)
□ Load testing (k6/Artillery)
```

**Final Output:**
- ✅ **Production API:** `https://api.xpiano.com`
- ✅ **Swagger Docs:** `https://api.xpiano.com/api/docs`
- ✅ **Health Check:** `https://api.xpiano.com/health`

---

## 👤 PERSON 2: WEB FRONTEND ENGINEER

### **WEEK 1-2: Foundation & Landing** 🎨

#### **Day 1-3: Project Setup**
```bash
web-demo/
├─ Next.js 14 (App Router) setup
├─ Tailwind CSS configuration
├─ TypeScript strict mode
├─ ESLint + Prettier
└─ Environment variables

□ Setup project structure
□ Install dependencies (axios, zustand, etc.)
□ Create design system components
□ Setup API client (axios instance)
```

#### **Day 4-10: Landing Page**
```typescript
web-demo/app/
├─ page.tsx              // Homepage
├─ layout.tsx            // Root layout
├─ globals.css           // Global styles
└─ components/
    ├─ Hero.tsx
    ├─ Features.tsx
    ├─ HowItWorks.tsx
    ├─ Testimonials.tsx
    ├─ CTA.tsx
    └─ Footer.tsx

Features:
□ Hero section with CTA
□ Features showcase (6-8 features)
□ How it works (3 steps)
□ Testimonials carousel
□ Pricing preview
□ Newsletter signup
□ Fully responsive (mobile-first)
```

**Output Week 1-2:**
- ✅ Landing page live at `localhost:3000`
- ✅ Responsive design (mobile + desktop)
- ✅ SEO-optimized (meta tags, structured data)

---

### **WEEK 3-4: Marketplace & Booking** 🎹

#### **Day 11-15: Piano Marketplace**
```typescript
web-demo/app/pianos/
├─ page.tsx              // Piano listing
├─ [id]/
│   └─ page.tsx          // Piano detail
└─ components/
    ├─ PianoCard.tsx
    ├─ FilterSidebar.tsx
    ├─ MapView.tsx       // Google Maps
    └─ SearchBar.tsx

Features:
□ Piano grid/list view
□ Filters (brand, price, keys, location)
□ Sort by (price, distance, rating)
□ Map view with warehouse markers
□ Piano detail with image gallery
□ Availability calendar
□ "Book Now" button
```

#### **Day 16-20: Authentication & Booking**
```typescript
web-demo/app/
├─ login/
│   └─ page.tsx          // OTP login
├─ booking/
│   └─ [pianoId]/
│       └─ page.tsx      // Checkout
└─ dashboard/
    └─ page.tsx          // User dashboard

Features:
□ OTP login flow
□ Phone number input with validation
□ OTP verification (6 digits)
□ Booking form (dates, address, notes)
□ Payment integration (VNPay sandbox)
□ Order confirmation page
□ User dashboard (orders, profile)
```

**Output Week 3-4:**
- ✅ `/pianos` - Browse marketplace
- ✅ `/pianos/[id]` - Piano details
- ✅ `/booking/[id]` - Checkout flow
- ✅ User authentication working

---

### **WEEK 5-6: Classroom (WebRTC + MIDI)** 📹

#### **Day 21-28: Video Call System**
```typescript
web-demo/app/classroom/
├─ [sessionId]/
│   └─ page.tsx
└─ components/
    ├─ VideoGrid.tsx
    ├─ ControlPanel.tsx
    ├─ ChatPanel.tsx
    └─ MIDIKeyboard.tsx

Libraries:
□ PeerJS for WebRTC
□ Socket.IO client
□ Web MIDI API

Features:
□ Video call (teacher ↔ student)
□ Mute/Unmute controls
□ Camera on/off
□ Screen sharing (optional)
□ Real-time chat
□ Connection status indicator
```

#### **Day 29-35: Web MIDI Integration**
```typescript
Features:
□ Detect MIDI devices (piano connected via USB)
□ Visual keyboard (88 keys)
□ Real-time note display
□ Note velocity visualization
□ Record & playback
□ Send MIDI data to teacher (via WebSocket)
```

**Web MIDI API Example:**
```typescript
// Request MIDI access
navigator.requestMIDIAccess()
  .then(access => {
    const inputs = access.inputs.values();
    for (let input of inputs) {
      input.onmidimessage = handleMIDIMessage;
    }
  });

function handleMIDIMessage(message) {
  const [command, note, velocity] = message.data;
  // Send to WebSocket
  socket.emit('midi-event', { note, velocity });
}
```

**Output Week 5-6:**
- ✅ `/classroom/[sessionId]` - Live classroom
- ✅ Video call working
- ✅ MIDI piano connection tested
- ✅ Chat functional

---

### **WEEK 7-8: Polish & Deploy** ✨

#### **Day 36-42: SEO & Performance**
```typescript
□ Meta tags for all pages
□ Open Graph images
□ Sitemap.xml generation
□ Robots.txt
□ Image optimization (next/image)
□ Code splitting
□ Bundle size optimization
□ Lighthouse score > 90
```

#### **Day 43-50: Deploy & Monitor**
```bash
□ Connect GitHub to Vercel
□ Setup production environment variables
□ Configure custom domain (xpiano.com)
□ Setup Google Analytics
□ Setup Sentry error tracking
□ Add FAQ page
□ Add Terms & Privacy pages
□ Blog setup (optional)
```

**Final Output:**
- ✅ **Production Website:** `https://xpiano.com`
- ✅ **Performance:** Lighthouse 95+
- ✅ **SEO:** Meta tags + structured data

---

## 👤 PERSON 3: MOBILE ENGINEER

### **WEEK 1-2: Project Setup & UI Shells** 📱

#### **Day 1-3: Flutter Project Init**
```bash
mobile/
├─ lib/
│   ├─ main.dart
│   ├─ app/
│   │   ├─ app.dart
│   │   ├─ routes.dart
│   │   └─ theme.dart
│   ├─ core/
│   │   ├─ api/
│   │   ├─ models/
│   │   └─ providers/
│   └─ features/
│       ├─ auth/
│       ├─ rental/
│       ├─ classroom/
│       └─ wallet/
└─ pubspec.yaml

Commands:
□ flutter create xpiano_mobile
□ Setup folder structure (per ui_components.dart)
□ Add dependencies (dio, provider, etc.)
```

**Key Dependencies:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.4.0                    # HTTP client
  provider: ^6.1.1               # State management
  google_maps_flutter: ^2.5.0    # Maps
  flutter_webrtc: ^0.9.46        # Video call
  flutter_midi: ^1.0.0           # MIDI
  socket_io_client: ^2.0.3       # WebSocket
  firebase_messaging: ^14.7.9    # Push notifications
  shared_preferences: ^2.2.2     # Local storage
```

#### **Day 4-10: Auth Screens**
```dart
lib/features/auth/
├─ screens/
│   ├─ splash_screen.dart
│   ├─ onboarding_screen.dart
│   ├─ login_screen.dart
│   └─ otp_screen.dart
└─ widgets/
    ├─ phone_input.dart
    └─ otp_input.dart

Features:
□ Splash screen with logo animation
□ Onboarding (3 slides)
□ Phone number input (Vietnam format)
□ OTP verification (6 digits)
□ Loading states
□ Error handling
```

**Output Week 1-2:**
- ✅ Flutter app runs on iOS simulator
- ✅ Flutter app runs on Android emulator
- ✅ Auth UI complete (no API yet)

---

### **WEEK 3-4: Core Features & API** 🔌

#### **Day 11-18: Piano Marketplace**
```dart
lib/features/rental/
├─ screens/
│   ├─ home_screen.dart
│   ├─ piano_list_screen.dart
│   ├─ piano_detail_screen.dart
│   └─ map_screen.dart
├─ widgets/
│   ├─ piano_card.dart
│   ├─ filter_bottom_sheet.dart
│   └─ warehouse_marker.dart
└─ rental_provider.dart

Features:
□ Home screen with categories
□ Piano list with pull-to-refresh
□ Google Maps with warehouse markers
□ Piano detail with image carousel
□ Filters & sorting
□ Search functionality
□ Favorites (local storage)
```

#### **Day 19-20: API Integration**
```dart
lib/core/api/
├─ api_client.dart
├─ endpoints.dart
└─ interceptors/
    └─ auth_interceptor.dart

Features:
□ Dio HTTP client setup
□ JWT token management
□ API error handling
□ Loading states
□ Retry logic
□ Offline mode (cache)
```

**Output Week 3-4:**
- ✅ Marketplace screens functional
- ✅ API integration working
- ✅ Real data from backend

---

### **WEEK 5-6: Advanced Features** 🎥

#### **Day 21-28: Classroom & Video Call**
```dart
lib/features/classroom/
├─ screens/
│   ├─ classroom_lobby_screen.dart
│   ├─ classroom_screen.dart
│   └─ classroom_settings_screen.dart
├─ widgets/
│   ├─ video_renderer.dart
│   ├─ control_panel.dart
│   ├─ chat_widget.dart
│   └─ virtual_piano.dart
└─ classroom_provider.dart

Features:
□ WebRTC video call (flutter_webrtc)
□ Audio controls (mute/unmute)
□ Video controls (camera on/off)
□ Hang up button
□ Picture-in-picture mode
□ Connection quality indicator
```

**Flutter WebRTC Setup:**
```dart
import 'package:flutter_webrtc/flutter_webrtc.dart';

class ClassroomScreen extends StatefulWidget {
  @override
  _ClassroomScreenState createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  
  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    _startCall();
  }
  
  Future<void> _startCall() async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true
    });
    _localRenderer.srcObject = stream;
  }
}
```

#### **Day 29-35: MIDI & Wallet**
```dart
lib/features/midi/
├─ midi_service.dart
└─ virtual_piano_widget.dart

lib/features/wallet/
├─ screens/
│   ├─ wallet_screen.dart
│   ├─ transaction_history_screen.dart
│   └─ withdrawal_screen.dart
└─ wallet_provider.dart

Features:
□ MIDI device connection (USB/Bluetooth)
□ Virtual keyboard (88 keys)
□ Note visualization
□ Wallet balance display
□ Transaction history
□ Commission tracking (F1, F2)
□ Withdrawal requests
```

**Output Week 5-6:**
- ✅ Video call working on both iOS & Android
- ✅ MIDI integration tested
- ✅ Wallet features complete

---

### **WEEK 7-8: Finalize & Deploy** 🚀

#### **Day 36-42: Polish & Testing**
```bash
□ UI/UX polish (animations, transitions)
□ Dark mode support (optional)
□ Localization (Vietnamese + English)
□ Error states & empty states
□ Loading skeletons
□ Pull-to-refresh on all lists
□ Image caching optimization
□ App icon & splash screen
```

#### **Day 43-47: Push Notifications**
```dart
Firebase Cloud Messaging:
□ Firebase project setup
□ iOS: APNs certificate
□ Android: google-services.json
□ Notification handlers
□ Deep linking
□ Local notifications
```

#### **Day 48-50: App Store Deployment**
```bash
iOS:
□ Create app in App Store Connect
□ Add screenshots (6.5" & 5.5")
□ Write app description
□ Set pricing & availability
□ Build & upload to TestFlight
□ Submit for beta review

Android:
□ Create app in Play Console
□ Add screenshots & feature graphic
□ Write app description
□ Create internal testing track
□ Upload AAB bundle
□ Submit for internal testing
```

**Final Output:**
- ✅ **iOS TestFlight:** `https://testflight.apple.com/join/xxxxx`
- ✅ **Android Internal:** Play Console internal testing
- ✅ Beta with 20-50 testers

---

## 🔄 DEPENDENCIES & SYNC POINTS

### **Critical Dependencies**

```
Week 1:
Person 1 completes Auth API
         ↓
Week 2:
Person 2 & 3 integrate login

Week 2:
Person 1 completes Users API
         ↓
Week 3:
Person 2 & 3 show user profile

Week 3:
Person 1 completes Pianos API
         ↓
Week 4:
Person 2 & 3 show marketplace

Week 5:
Person 1 completes WebSocket Gateway
         ↓
Week 6:
Person 2 & 3 integrate video call
```

### **API Contract Meeting (Day 1)**

**Critical:** All 3 people must agree on API contracts before coding

```yaml
Example API Contract:

POST /api/auth/login
Request:
  {
    "phone": "+84901234567"
  }
Response:
  {
    "success": true,
    "message": "OTP sent",
    "expires_in": 300
  }

POST /api/auth/verify-otp
Request:
  {
    "phone": "+84901234567",
    "otp": "123456"
  }
Response:
  {
    "access_token": "jwt_token_here",
    "refresh_token": "refresh_token_here",
    "user": {
      "id": "uuid",
      "phone": "+84901234567",
      "full_name": "Nguyen Van A"
    }
  }
```

**Person 1** creates Swagger docs → **Person 2 & 3** implement according to specs

---

## 📋 DAILY STANDUP FORMAT

**Time:** 9:00 AM (15 minutes max)

```
👤 Person 1 (Backend):
  Yesterday: Completed Auth module
  Today: Start Warehouses module with PostGIS
  Blockers: None

👤 Person 2 (Web):
  Yesterday: Landing page responsive done
  Today: Start Piano listing page
  Blockers: Waiting for Pianos API (ETA: Tomorrow)

👤 Person 3 (Mobile):
  Yesterday: Auth screens UI complete
  Today: Integrate login API
  Blockers: None

Action Items:
- Person 1: Deploy staging API by EOD
- Person 2: Share Figma designs with Person 3
- All: Code review session at 4 PM
```

---

## 🛠️ TOOLS & SETUP

### **Communication**
```
- Slack/Discord: Daily chat
- Zoom/Google Meet: Daily standup
- Notion: Documentation
- Linear/Jira: Task tracking
```

### **Code Management**
```bash
Git Flow:
main (production)
├─ develop (staging)
│   ├─ feature/backend-auth (Person 1)
│   ├─ feature/web-marketplace (Person 2)
│   └─ feature/mobile-setup (Person 3)

Branch naming:
- feature/[module-name]
- bugfix/[issue-description]
- hotfix/[critical-fix]

Commit format:
feat: add login API
fix: resolve OTP validation bug
docs: update API documentation
```

### **Shared Resources**
```
- Supabase: https://supabase.com/dashboard
  └─ All have admin access
  
- Vercel: https://vercel.com/xpiano
  └─ Person 2 is owner, Person 1 has access
  
- Railway: https://railway.app/project/xpiano
  └─ Person 1 is owner, Person 2 has viewer
  
- Figma: https://figma.com/xpiano
  └─ All have edit access
  
- Google Cloud (Maps API):
  └─ Shared API key in .env.shared
```

---

## 📊 MILESTONES & DELIVERABLES

### **Week 2 Milestone: Foundation Complete** ✅
```
□ Backend API running at localhost:3000
□ Web landing page at localhost:3001
□ Mobile app runs on emulator
□ Auth flow working (all 3 platforms)
□ Team demo: Show login flow end-to-end
```

### **Week 4 Milestone: Core Features** ✅
```
□ Backend: All CRUD APIs complete
□ Web: Marketplace + booking functional
□ Mobile: Marketplace screens + API integration
□ Team demo: Book a piano from web & mobile
```

### **Week 6 Milestone: Advanced Features** ✅
```
□ Backend: WebSocket + Commission working
□ Web: Classroom with video call tested
□ Mobile: Video call functional
□ Team demo: Live classroom session
```

### **Week 8 Milestone: Launch** 🚀
```
□ Backend: Deployed to production
□ Web: Live at xpiano.com
□ Mobile: TestFlight + Play Console beta
□ Team demo: Full user journey presentation
```

---

## 🎯 SUCCESS METRICS

### **Technical Metrics**
```
Backend:
✅ API response time < 200ms (avg)
✅ 99% uptime
✅ Zero critical security vulnerabilities
✅ 80%+ test coverage

Web:
✅ Lighthouse score > 90
✅ First Contentful Paint < 1.5s
✅ Time to Interactive < 3s
✅ Mobile responsive (100%)

Mobile:
✅ App size < 50MB
✅ Crash rate < 1%
✅ Cold start < 2s
✅ 4.5+ star rating goal
```

### **Business Metrics (Post-Launch)**
```
Week 9-12 Goals:
- 100 beta users registered
- 20 orders completed
- 5 partner warehouses onboarded
- 10 teachers active
- $0 infrastructure cost (free tiers)
```

---

## 💰 INFRASTRUCTURE COSTS

### **Week 1-4: Development (FREE)**
```
✅ Vercel: Free tier
✅ Supabase: Free tier (500MB)
✅ Railway: $5 credit free
✅ Twilio: $15 credit free
✅ Cloudinary: Free tier
```

### **Week 5-8: Beta Testing ($25/month)**
```
- Railway: $5/month
- SMS OTP: $20/month (after trial)
Total: $25/month
```

### **Post-Launch: Production ($105/month)**
```
- Supabase Pro: $25/month
- Railway: $20/month
- Upstash Redis: $10/month
- SMS OTP: $50/month
- VNPay fees: 2-3% per transaction
Total: ~$105/month
```

---

## 📝 QUICK START CHECKLIST

### **Day 1 Morning (All Together)**
```
□ Git repository setup
  - Create GitHub org: github.com/xpiano
  - Create repos: backend, web-demo, mobile
  - Add all team members
  - Setup branch protection (main, develop)

□ Access to shared services
  - Supabase: Person 1 creates project, invites team
  - Vercel: Person 2 creates project, invites Person 1
  - Railway: Person 1 creates project
  - Slack/Discord: Create channels

□ API Contract Meeting (1 hour)
  - Define all endpoints
  - Request/Response formats
  - Error codes
  - Authentication flow
  - Person 1 creates Swagger template

□ Environment variables setup
  - Create .env.example for each repo
  - Share secrets via 1Password/LastPass
  - Document in README
```

### **Day 1 Afternoon (Start Coding)**
```
👤 Person 1:
  □ cd backend && npm install
  □ Setup Docker Compose (postgres + redis)
  □ Initialize Prisma
  □ Create auth module structure

👤 Person 2:
  □ cd web-demo && npm install
  □ Setup Tailwind
  □ Create components folder
  □ Start landing page

👤 Person 3:
  □ flutter create xpiano_mobile
  □ Setup folder structure
  □ Add dependencies
  □ Create auth screens
```

---

## 🚨 RISK MANAGEMENT

### **Technical Risks**

#### **Risk 1: WebRTC Connection Issues**
```
Problem: Video call fails on mobile networks (4G/5G)
Mitigation:
- Use TURN server (Twilio/Metered)
- Implement reconnection logic
- Fallback to audio-only mode
- Test on real devices early (Week 5)
```

#### **Risk 2: Web MIDI Browser Support**
```
Problem: Safari doesn't support Web MIDI API
Impact: 30% of users (iPhone Safari)
Mitigation:
- Detect browser and show warning
- Suggest Chrome/Edge
- Consider WebAssembly MIDI parser
- Or: PWA with USB passthrough
```

#### **Risk 3: SMS OTP Costs**
```
Problem: OTP costs scale with users
Mitigation:
- Implement rate limiting (1 OTP/2 min)
- Add reCAPTCHA to prevent abuse
- Consider alternative: Email OTP
- Budget: $50/month for 250 OTPs
```

### **Team Coordination Risks**

#### **Risk 1: Merge Conflicts**
```
Problem: Multiple people editing same files
Mitigation:
- Clear module ownership
- Feature branches with short lifespan
- Daily code syncs
- Pull request reviews before merge
```

#### **Risk 2: API Contract Changes**
```
Problem: Backend changes API, breaks frontend
Mitigation:
- API versioning (/api/v1/)
- Swagger auto-generated docs
- No breaking changes without announcement
- Staging environment for testing
```

---

## 📚 DOCUMENTATION REQUIREMENTS

### **Backend (Person 1)**
```
□ README.md with setup instructions
□ API documentation (Swagger)
□ Database schema diagram
□ Environment variables guide
□ Deployment guide
□ Architecture decision records (ADRs)
```

### **Web (Person 2)**
```
□ README.md with dev setup
□ Component documentation (Storybook optional)
□ Environment variables guide
□ Deployment guide (Vercel)
□ Browser compatibility notes
□ Performance optimization guide
```

### **Mobile (Person 3)**
```
□ README.md with Flutter setup
□ Build instructions (iOS + Android)
□ Environment variables guide
□ App Store submission guide
□ Push notification setup guide
□ Testing guide (device + emulator)
```

---

## 🎉 LAUNCH DAY CHECKLIST (Week 8, Day 50)

### **Backend**
```
□ Production database backed up
□ Environment variables verified
□ Health check endpoint working
□ Monitoring alerts configured (Sentry)
□ Rate limiting enabled
□ CORS configured correctly
□ SSL certificate valid
```

### **Web**
```
□ Custom domain configured (xpiano.com)
□ SSL certificate active
□ Meta tags & OG images set
□ Google Analytics tracking
□ Sitemap submitted to Google
□ Robots.txt configured
□ 404 page designed
□ Terms & Privacy pages live
```

### **Mobile**
```
□ TestFlight build submitted
□ Play Console internal testing live
□ App screenshots uploaded (all sizes)
□ App description written
□ Privacy policy link added
□ Support email configured
□ 20 beta testers invited
□ Feedback form ready
```

### **Marketing**
```
□ Social media accounts created
  - Facebook: facebook.com/xpiano
  - Instagram: instagram.com/xpiano
  - TikTok: tiktok.com/@xpiano
□ Landing page live
□ Blog post: "Introducing Xpiano"
□ Press release ready
□ Beta tester email campaign
```

---

## 📞 SUPPORT & ESCALATION

### **Blockers Escalation Path**
```
1. Try to resolve yourself (30 min)
2. Ask in team chat (Slack)
3. Schedule 15-min call with relevant person
4. If still blocked, daily standup discussion
```

### **Critical Issues (Production Down)**
```
1. Announce in #critical channel
2. All hands on deck
3. Person 1 leads backend issues
4. Person 2 leads web issues
5. Person 3 leads mobile issues
6. Post-mortem document after resolution
```

---

## 🎯 NEXT STEPS (START NOW)

### **Immediate Actions (Today)**
```
□ Person 1: Setup backend repo + Docker Compose
□ Person 2: Setup web-demo repo + Tailwind
□ Person 3: Run `flutter create xpiano_mobile`
□ All: Schedule API Contract Meeting (tomorrow 9 AM)
□ All: Clone repos and verify local setup
```

### **This Week Goals**
```
□ Auth flow working end-to-end (all 3 platforms)
□ First code deployed to staging
□ Team demo on Friday afternoon
```

---

## 📖 APPENDIX

### **A. Useful Commands**

#### **Backend**
```bash
# Start development
npm run start:dev

# Run migrations
npx prisma migrate dev

# Generate Prisma client
npx prisma generate

# Seed database
npm run seed

# Run tests
npm test
```

#### **Web**
```bash
# Start development
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Lint code
npm run lint
```

#### **Mobile**
```bash
# Run on iOS
flutter run -d ios

# Run on Android
flutter run -d android

# Build iOS
flutter build ios

# Build Android APK
flutter build apk

# Build Android App Bundle
flutter build appbundle
```

### **B. Key Endpoints Reference**

```yaml
Auth:
  POST /api/auth/login
  POST /api/auth/verify-otp
  POST /api/auth/refresh
  POST /api/auth/logout

Users:
  GET /api/users/me
  PATCH /api/users/me
  GET /api/users/:id

Warehouses:
  GET /api/warehouses?lat=X&lng=Y
  GET /api/warehouses/:id
  POST /api/warehouses (partner only)

Pianos:
  GET /api/pianos
  GET /api/pianos/:id
  GET /api/pianos/:id/availability

Orders:
  POST /api/orders
  GET /api/orders/my-orders
  GET /api/orders/:id
  PATCH /api/orders/:id/status

Wallet:
  GET /api/wallet
  GET /api/wallet/transactions
  POST /api/wallet/withdraw

WebSocket:
  CONNECT ws://api/classroom
  EVENT: join-room
  EVENT: leave-room
  EVENT: chat-message
  EVENT: midi-event
```

---

**END OF DEVELOPMENT PLAN**

**Questions? Contact:**
- Technical Lead: [Person 1 email]
- Project Manager: [Your email]
- Slack: #xpiano-dev

**Last Updated:** February 5, 2026  
**Version:** 1.0
