# Profile & Booking History Feature

## ✅ Completed Tasks

### 1. Database & Models
- Updated `Booking` model to support joined data (Piano Name & Image).
- Implemented `SupabaseService.getMyBookings()`:
  - Fetches all bookings for the user.
  - Joins with `pianos` table to get details.
  - Orders by `start_time` descending.
- Implemented `SupabaseService.cancelBooking(id)`:
  - Updates status to `cancelled`.

### 2. Profile Screen (`lib/screens/profile_screen.dart`)
- **Header:**
  - Avatar & Name (Placeholder/Hardcoded).
  - Stats: Bookings count, Practice hours, Rank.
- **Booking History List:**
  - Displays booking cards with:
    - Piano Image & Name.
    - Date & Time.
    - Price.
    - Status Badge (Confirmed, Pending, Cancelled, Completed).
- **Interactions:**
  - **Pull-to-refresh:** Reloads the list.
  - **Cancel Action:** Users can cancel upcoming bookings. Includes confirmation dialog.
  - **Empty State:** Shows friendly message when no bookings exist.

### 3. Navigation (`lib/main.dart`)
- Implemented **Tab Navigation** using `IndexedStack`.
- Tabs:
  1. **Home** (Video Feed).
  2. **Khám phá** (Placeholder).
  3. **Tạo mới** (Placeholder).
  4. **Hộp thư** (Message - Placeholder).
  5. **Hồ sơ** (Profile Screen).
- Updated Bottom Navigation Bar to be fully interactive.

## 🚀 How to Test

1. **Open the App.**
2. **Tab "Hồ sơ" (Profile Icon):** Tap the rightmost icon in the bottom bar.
3. **View Bookings:** You should see your recent bookings (from the previous task).
4. **Cancel a Booking:**
   - Find a "Confirmed" or "Pending" booking in the future.
   - Tap "Hủy" (Cancel).
   - Confirm the dialog.
   - The status should change to "Đã hủy" (Red).
5. **Create New Booking:**
   - Go to Home -> Mượn Đàn -> Create Booking.
   - Go back to Profile to see it appear in the list.

## ⚠️ Notes
- The "Education" flow is currently skipped as requested.
- User authentication is currently using anonymous/hardcoded identity for the MVP scope (Supabase Auth is initialized but user mapping is simple).
