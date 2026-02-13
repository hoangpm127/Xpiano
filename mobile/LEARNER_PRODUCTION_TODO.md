# 🚀 LEARNER DASHBOARD - PRODUCTION ROADMAP

## ✅ COMPLETED (Current MVP)

### UI/UX
- ✅ Learner dashboard layout với 7 sections
- ✅ Header với avatar, name, badge
- ✅ Quick stats cards (3 metrics)
- ✅ Empty states với clear CTAs
- ✅ Pull-to-refresh functionality
- ✅ Smooth scrolling với CustomScrollView
- ✅ Material Design 3 styling
- ✅ Gold theme consistency

### Data Integration
- ✅ Read learner stats từ Supabase
- ✅ Query upcoming bookings
- ✅ Query completed bookings
- ✅ Query active rentals (with fallback)
- ✅ Query enrolled courses
- ✅ Payment history display
- ✅ Affiliate placeholder

### Routing
- ✅ Role-based dashboard render
- ✅ Teacher dashboard unaffected
- ✅ Guest view preserved
- ✅ Navigation integrity maintained

---

## 🔥 PRIORITY 1 - CRITICAL FOR LAUNCH

### P1.1 - Booking Creation Flow
**Status**: ❌ Not Started  
**Effort**: 5 days  
**Blockers**: None

**Requirements**:
- [ ] Teacher availability calendar view
- [ ] Time slot selection UI
- [ ] Duration picker (30/60/90 minutes)
- [ ] Price calculation & display
- [ ] Booking confirmation dialog
- [ ] Payment gateway integration
- [ ] Success/failure handling
- [ ] Email confirmation to learner & teacher

**Files to Create/Edit**:
- `lib/screens/book_lesson_screen.dart`
- `lib/widgets/teacher_calendar_widget.dart`
- `lib/services/booking_service.dart`
- Add to `supabase_service.dart`: `createBooking()`

**Database**:
```sql
-- bookings table (already exists, verify schema)
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS payment_status TEXT DEFAULT 'pending';
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS payment_method TEXT;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS transaction_id TEXT;
```

---

### P1.2 - Payment Integration
**Status**: ❌ Not Started  
**Effort**: 7 days  
**Blockers**: Merchant account setup

**Requirements**:
- [ ] VNPay SDK integration (or Stripe)
- [ ] Payment flow UI
- [ ] Webhook handler for payment confirmation
- [ ] Refund logic
- [ ] Receipt generation
- [ ] Payment failure retry

**Files to Create**:
- `lib/services/payment_service.dart`
- `lib/screens/payment_screen.dart`
- `lib/models/payment.dart`

**Dependencies**:
```yaml
# pubspec.yaml
dependencies:
  vnpay_flutter: ^1.0.0  # Or stripe_flutter
  pdf: ^3.10.0  # For invoice generation
```

**Database**:
```sql
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  booking_id UUID REFERENCES bookings(id) ON DELETE SET NULL,
  amount DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'VND',
  status TEXT NOT NULL, -- pending, completed, failed, refunded
  payment_method TEXT, -- vnpay, momo, stripe, cash
  transaction_id TEXT UNIQUE,
  metadata JSONB,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_payments_user ON payments(user_id);
CREATE INDEX idx_payments_booking ON payments(booking_id);
CREATE INDEX idx_payments_status ON payments(status);
```

---

### P1.3 - Meeting Room (Video Call)
**Status**: ❌ Not Started  
**Effort**: 5 days  
**Blockers**: Agora/Jitsi account

**Requirements**:
- [ ] Agora.io SDK setup (or Jitsi Meet)
- [ ] Room creation when booking confirmed
- [ ] "Join Meeting" button active 15 min before start
- [ ] Screen sharing support
- [ ] Chat during call
- [ ] Recording (optional)

**Files to Create**:
- `lib/services/meeting_service.dart`
- `lib/screens/meeting_room_screen.dart`

**Dependencies**:
```yaml
dependencies:
  agora_rtc_engine: ^6.2.0
  # OR
  jitsi_meet_flutter_sdk: ^9.0.0
```

**Database**:
```sql
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS meeting_url TEXT;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS meeting_id TEXT;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS meeting_password TEXT;
```

---

## 🎯 PRIORITY 2 - IMPORTANT FOR USER RETENTION

### P2.1 - Profile Editing
**Status**: ❌ Not Started  
**Effort**: 3 days

**Requirements**:
- [ ] Edit full_name, phone, address
- [ ] Upload/crop avatar
- [ ] Email change (with verification)
- [ ] Password change
- [ ] Validation & error handling

**Files to Create**:
- `lib/screens/edit_profile_screen.dart`
- `lib/screens/change_password_screen.dart`

---

### P2.2 - Booking Management
**Status**: ❌ Not Started  
**Effort**: 4 days

**Requirements**:
- [ ] Cancel booking (with policy check)
- [ ] Reschedule booking
- [ ] Rate & review after completed lesson
- [ ] View booking history with filters

**Files to Edit**:
- `lib/screens/booking_detail_screen.dart` (create)
- `lib/screens/learner_dashboard_screen.dart` (add navigation)

**Database**:
```sql
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
  teacher_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  learner_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE bookings ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMP;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS cancelled_by UUID REFERENCES profiles(id);
```

---

### P2.3 - Push Notifications
**Status**: ❌ Not Started  
**Effort**: 3 days

**Requirements**:
- [ ] Firebase Cloud Messaging setup
- [ ] Notification for booking confirmation
- [ ] Reminder 1 hour before lesson
- [ ] Teacher message notification
- [ ] Payment success notification

**Dependencies**:
```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.0
  flutter_local_notifications: ^16.3.0
```

---

## 📊 PRIORITY 3 - NICE TO HAVE

### P3.1 - Rental System Full Flow
**Status**: ❌ Not Started  
**Effort**: 6 days

**Requirements**:
- [ ] Browse available pianos
- [ ] Rental request submission
- [ ] Contract generation & e-signing
- [ ] Deposit payment
- [ ] Delivery scheduling
- [ ] Rental extension
- [ ] Return scheduling
- [ ] Damage assessment

**Database**:
```sql
CREATE TABLE IF NOT EXISTS pianos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID REFERENCES profiles(id),
  name TEXT NOT NULL,
  brand TEXT,
  model TEXT,
  year INTEGER,
  condition TEXT, -- new, excellent, good, fair
  monthly_price DECIMAL(10,2),
  deposit_amount DECIMAL(10,2),
  location TEXT,
  images TEXT[],
  available BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rentals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  piano_id UUID REFERENCES pianos(id),
  learner_id UUID REFERENCES profiles(id),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  monthly_price DECIMAL(10,2),
  deposit_paid DECIMAL(10,2),
  status TEXT, -- pending, active, completed, cancelled
  contract_url TEXT,
  delivery_address TEXT,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

---

### P3.2 - Affiliate System
**Status**: ❌ Not Started  
**Effort**: 5 days

**Requirements**:
- [ ] Track referral signups
- [ ] Commission calculation (% of first booking)
- [ ] Withdraw earnings UI
- [ ] Payment to bank account
- [ ] Referral analytics dashboard

**Database**:
```sql
CREATE TABLE IF NOT EXISTS referrals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  referrer_id UUID REFERENCES profiles(id),
  referred_id UUID REFERENCES profiles(id),
  referral_code TEXT NOT NULL,
  status TEXT, -- pending, converted, paid
  commission_amount DECIMAL(10,2),
  booking_id UUID REFERENCES bookings(id),
  created_at TIMESTAMP DEFAULT NOW(),
  converted_at TIMESTAMP,
  paid_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS affiliate_withdrawals (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id),
  amount DECIMAL(10,2),
  bank_account TEXT,
  status TEXT, -- pending, processing, completed, rejected
  created_at TIMESTAMP DEFAULT NOW(),
  processed_at TIMESTAMP
);
```

---

### P3.3 - Progress Tracking
**Status**: ❌ Not Started  
**Effort**: 4 days

**Requirements**:
- [ ] Practice log (manual entry)
- [ ] Learning goals
- [ ] Achievement badges
- [ ] Progress charts
- [ ] Skills dashboard

**Database**:
```sql
CREATE TABLE IF NOT EXISTS practice_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  learner_id UUID REFERENCES profiles(id),
  date DATE NOT NULL,
  duration_minutes INTEGER,
  notes TEXT,
  pieces_practiced TEXT[],
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS achievements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  learner_id UUID REFERENCES profiles(id),
  type TEXT, -- first_lesson, 10_lessons, 100_hours_practice, etc.
  title TEXT,
  description TEXT,
  earned_at TIMESTAMP DEFAULT NOW()
);
```

---

### P3.4 - In-App Chat
**Status**: ❌ Not Started  
**Effort**: 7 days

**Requirements**:
- [ ] Chat UI (conversation list + message thread)
- [ ] Real-time messaging (Supabase Realtime)
- [ ] Image sharing
- [ ] File sharing (sheet music PDF)
- [ ] Unread badge
- [ ] Push notification for new messages

**Database**:
```sql
CREATE TABLE IF NOT EXISTS conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  learner_id UUID REFERENCES profiles(id),
  teacher_id UUID REFERENCES profiles(id),
  last_message TEXT,
  last_message_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES profiles(id),
  content TEXT,
  type TEXT, -- text, image, file
  file_url TEXT,
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at DESC);
```

---

## 🔬 PRIORITY 4 - ANALYTICS & OPTIMIZATION

### P4.1 - Analytics Dashboard
**Status**: ❌ Not Started  
**Effort**: 3 days

**Requirements**:
- [ ] Total learning hours
- [ ] Spending trends chart
- [ ] Practice streaks
- [ ] Teacher comparison (hours per teacher)
- [ ] Favorite pieces

---

### P4.2 - Performance Optimization
**Status**: ❌ Not Started  
**Effort**: Ongoing

**Tasks**:
- [ ] Implement pagination for booking history
- [ ] Cache user profile
- [ ] Image lazy loading
- [ ] Optimize Supabase queries
- [ ] Add loading skeletons

---

### P4.3 - Offline Support
**Status**: ❌ Not Started  
**Effort**: 4 days

**Requirements**:
- [ ] Cache dashboard data locally
- [ ] View bookings offline
- [ ] Sync when online
- [ ] Conflict resolution

**Dependencies**:
```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
```

---

## 🎨 PRIORITY 5 - UI/UX ENHANCEMENTS

### P5.1 - Dark Mode
**Status**: ❌ Not Started  
**Effort**: 2 days

### P5.2 - Multi-language (i18n)
**Status**: ❌ Not Started  
**Effort**: 3 days

### P5.3 - Accessibility
**Status**: ❌ Not Started  
**Effort**: 2 days

### P5.4 - Animations & Transitions
**Status**: ❌ Not Started  
**Effort**: 2 days

---

## 📋 IMPLEMENTATION ORDER (Recommended)

### Sprint 1 (Week 1-2): Core Booking
1. P1.1 - Booking creation flow
2. P1.2 - Payment integration (basic)
3. P2.1 - Profile editing

### Sprint 2 (Week 3-4): Communication
4. P1.3 - Meeting room
5. P2.2 - Booking management
6. P3.4 - In-app chat (basic)

### Sprint 3 (Week 5-6): Retention
7. P2.3 - Push notifications
8. P3.2 - Affiliate system
9. P3.3 - Progress tracking

### Sprint 4 (Week 7-8): Advanced
10. P3.1 - Rental system
11. P4.1 - Analytics
12. P4.2 - Performance optimization

### Sprint 5 (Week 9-10): Polish
13. P4.3 - Offline support
14. P5.1 - Dark mode
15. P5.2 - Multi-language

---

## 🔐 SECURITY CONSIDERATIONS

### Must Implement
- [ ] Rate limiting on booking creation
- [ ] Input validation & sanitization
- [ ] RLS policies for all tables
- [ ] Payment webhook signature verification
- [ ] File upload size limits
- [ ] XSS prevention
- [ ] CSRF tokens where applicable

---

## 🧪 TESTING STRATEGY

### Unit Tests
- [ ] Service layer methods
- [ ] Model parsing
- [ ] Validation logic

### Integration Tests
- [ ] Booking creation flow
- [ ] Payment flow
- [ ] Supabase queries

### E2E Tests
- [ ] Complete learner journey
- [ ] Payment success/failure scenarios
- [ ] Meeting join flow

---

## 📝 DOCUMENTATION NEEDED

- [ ] API documentation for all service methods
- [ ] User guide for learners
- [ ] Admin guide for managing bookings
- [ ] Developer onboarding doc
- [ ] Database schema diagram
- [ ] Architecture decision records (ADRs)

---

## 🚀 DEPLOYMENT CHECKLIST

### Pre-Launch
- [ ] All P1 features tested
- [ ] Database migrations applied
- [ ] Supabase RLS policies verified
- [ ] Payment gateway merchant account live
- [ ] Meeting room service account configured
- [ ] Push notification certificates uploaded
- [ ] Error tracking setup (Sentry/Firebase Crashlytics)
- [ ] Analytics setup (Google Analytics/Mixpanel)

### Launch Day
- [ ] Monitor error rates
- [ ] Watch payment success rates
- [ ] Monitor Supabase quota
- [ ] User feedback channels open

### Post-Launch (Week 1)
- [ ] Hot patch critical bugs
- [ ] Collect user feedback
- [ ] Analyze usage metrics
- [ ] Plan next sprint

---

## 📞 SUPPORT CONTACTS

- **Payment Issues**: payment-support@xpiano.com
- **Technical Bugs**: dev@xpiano.com
- **Feature Requests**: product@xpiano.com

