# ✅ LEARNER DASHBOARD - ACCEPTANCE TEST CHECKLIST

## Phase 1: Initial UI Display ✅
- [ ] 1. Login bằng tài khoản learner
- [ ] 2. Vào tab "Hồ sơ"
- [ ] 3. Thấy header với avatar, tên, badge "🎓 Học viên"
- [ ] 4. Thấy 3 stat cards (Đã hoàn thành, Sắp tới, Đàn đang thuê)
- [ ] 5. Không crash nếu chưa có data

## Phase 2: Empty States ✅
- [ ] 6. Section "Khóa học" hiển thị empty state nếu chưa có
- [ ] 7. Section "Lịch học" hiển thị empty state nếu chưa có
- [ ] 8. Section "Thuê đàn" hiển thị empty state nếu chưa có
- [ ] 9. Empty states có icon, title, subtitle, action button đẹp

## Phase 3: Sections Display ✅
- [ ] 10. Thấy section "📚 Khóa học của tôi"
- [ ] 11. Thấy section "⏰ Lịch học sắp tới"
- [ ] 12. Thấy section "🎹 Đàn đang thuê"
- [ ] 13. Thấy section "💳 Thanh toán" với tổng chi phí
- [ ] 14. Thấy section "🎁 Giới thiệu bạn bè" với affiliate
- [ ] 15. Thấy section "⚙️ Cài đặt"

## Phase 4: Data Display (nếu có booking)
- [ ] 16. Booking cards hiển thị tên teacher, thời gian, duration
- [ ] 17. Status badge hiển thị đúng màu (confirmed=green, pending=orange)
- [ ] 18. Buttons "Chi tiết" và "Vào lớp" hoạt động (TODO placeholder OK)
- [ ] 19. Course cards hiển thị avatar teacher, tên khóa học
- [ ] 20. Button "Đặt lịch" có thể click (TODO placeholder OK)

## Phase 5: Pull-to-Refresh
- [ ] 21. Kéo xuống từ trên để refresh
- [ ] 22. Loading indicator hiển thị
- [ ] 23. Data reload thành công

## Phase 6: Affiliate Section
- [ ] 24. Mã giới thiệu hiển thị (8 ký tự đầu của user ID)
- [ ] 25. Copy button hoạt động
- [ ] 26. Toast "Đã sao chép mã giới thiệu" hiển thị

## Phase 7: Settings Section
- [ ] 27. "Thông tin cá nhân" có thể click (TODO OK)
- [ ] 28. "Đổi mật khẩu" có thể click (TODO OK)
- [ ] 29. "Nâng cấp thành giáo viên" hiển thị
- [ ] 30. "Đăng xuất" hiển thị dialog xác nhận

## Phase 8: Logout Flow
- [ ] 31. Click "Đăng xuất"
- [ ] 32. Dialog xác nhận hiển thị
- [ ] 33. Click "Đăng xuất" → về guest view
- [ ] 34. Click "Hủy" → đóng dialog, vẫn ở dashboard

## Phase 9: Navigation Integrity
- [ ] 35. Teacher dashboard KHÔNG bị ảnh hưởng
- [ ] 36. Feed tab hoạt động bình thường
- [ ] 37. Explore tab hoạt động bình thường
- [ ] 38. Inbox tab hoạt động bình thường
- [ ] 39. Bottom navigation bar hiển thị đúng

## Phase 10: Performance
- [ ] 40. Dashboard load < 2 giây
- [ ] 41. Scroll mượt mà
- [ ] 42. Không memory leak khi switch tabs nhiều lần
- [ ] 43. Hot reload hoạt động không crash

---

## 🚀 QUICK TEST SCRIPT

```bash
# 1. Hot reload app
cd mobile
flutter run -d <device-id>

# 2. Login as learner
# Email: learner@test.com
# Password: yourpassword

# 3. Navigate to Profile tab (bottom right icon)

# 4. Verify dashboard displays

# 5. Pull to refresh

# 6. Test copy affiliate code

# 7. Test logout flow

# 8. Login as teacher → verify teacher dashboard still works

# 9. Switch back to learner → verify no cross-contamination
```

---

## ⚠️ KNOWN LIMITATIONS (TODO Production)

### Phase 1 - Core Features
- [ ] Meeting room integration (Agora/Jitsi)
- [ ] Payment gateway (VNPay/Momo/Stripe)
- [ ] Invoice generation & download
- [ ] Push notifications for upcoming bookings
- [ ] In-app messaging with teachers

### Phase 2 - Booking System
- [ ] Real-time booking calendar
- [ ] Booking cancellation policy
- [ ] Reschedule booking flow
- [ ] Rate & review after lesson
- [ ] Homework submission interface

### Phase 3 - Rental System
- [ ] Piano rental contract signing
- [ ] Rental extension/renewal flow
- [ ] Deposit & refund logic
- [ ] Piano delivery tracking
- [ ] Damage report submission

### Phase 4 - Payment & Finance
- [ ] Payment history filtering (by date, type)
- [ ] Invoice export (PDF)
- [ ] Refund request flow
- [ ] Multiple payment methods
- [ ] Auto-pay subscription

### Phase 5 - Affiliate System
- [ ] Referral link generation
- [ ] Track referral conversions
- [ ] Withdraw affiliate earnings
- [ ] Tiered commission system
- [ ] Referral analytics dashboard

### Phase 6 - Profile Management
- [ ] Edit profile (name, phone, address)
- [ ] Upload/change avatar
- [ ] Change password flow
- [ ] Email verification
- [ ] Two-factor authentication

### Phase 7 - Course Progress
- [ ] Learning progress tracking
- [ ] Practice logs
- [ ] Achievement badges
- [ ] Skill level assessment
- [ ] Progress reports

### Phase 8 - Communication
- [ ] In-app chat with teacher
- [ ] Video call integration
- [ ] File sharing (sheet music, recordings)
- [ ] Class notes from teacher
- [ ] Feedback & comments

### Phase 9 - Analytics
- [ ] Learning time statistics
- [ ] Practice streaks
- [ ] Spending trends
- [ ] Goal setting & tracking
- [ ] Performance insights

### Phase 10 - Advanced
- [ ] Multi-language support
- [ ] Offline mode (view cache)
- [ ] Dark mode
- [ ] Accessibility features
- [ ] Export all data (GDPR)

---

## 📊 METRICS TO TRACK

### User Engagement
- Active learners (last 7 days)
- Average bookings per learner per month
- Course completion rate
- Retention rate (30/60/90 days)

### Financial
- Average order value
- Total GMV (Gross Merchandise Value)
- Affiliate conversion rate
- Refund rate

### Quality
- Average lesson rating
- Teacher response time
- Booking cancellation rate
- Support ticket volume

---

## 🎯 SUCCESS CRITERIA

### MVP Launch (Current Phase)
✅ Learner can view their bookings
✅ Learner can see their learning history
✅ Learner can access rental information
✅ Learner can view payment summary
✅ Learner can share referral code
✅ No crashes on empty data states
✅ Teacher dashboard unaffected

### V2 (Next Phase)
- [ ] Real booking creation flow
- [ ] Payment integration
- [ ] Meeting room works
- [ ] Push notifications enabled
- [ ] Profile editing complete

### V3 (Future)
- [ ] Full rental system
- [ ] Affiliate payout system
- [ ] Progress tracking
- [ ] Chat system
- [ ] Mobile app optimizations

---

## 🐛 COMMON ISSUES & FIXES

### Issue: Dashboard shows loading forever
**Fix**: Check Supabase connection, verify user is logged in

### Issue: Stats show 0 even with bookings
**Fix**: Verify bookings table has `learner_id` column and correct user ID

### Issue: Course cards empty but bookings exist
**Fix**: Check join query with teacher_profiles table, ensure data integrity

### Issue: Affiliate code not copying
**Fix**: Check clipboard permissions on device

### Issue: Logout doesn't work
**Fix**: Verify SupabaseService.signOut() implementation

### Issue: Navigation broken after implementing
**Fix**: Check route guards in profile_screen.dart, ensure role detection logic

---

## 📝 NOTES

- All database queries are read-only for now
- Write operations (booking, payment, rental) are TODO
- Empty states are designed to guide users to next action
- UI follows existing app design language (gold theme)
- No breaking changes to existing features
- Compatible with current schema (bookings, rentals tables)

