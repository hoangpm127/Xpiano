# 🎹 Flutter Setup Guide for Xpiano

## 📦 Step 1: Install Flutter (5-10 phút)

### Option A: Tự động (Khuyến nghị)
```powershell
# Tải Flutter SDK
Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.19.0-stable.zip" -OutFile "$env:USERPROFILE\Downloads\flutter.zip"

# Giải nén vào C:\
Expand-Archive -Path "$env:USERPROFILE\Downloads\flutter.zip" -DestinationPath "C:\"

# Thêm Flutter vào PATH
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\flutter\bin", "User")

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","User")
```

### Option B: Thủ công
1. Download Flutter: https://flutter.dev/docs/get-started/install/windows
2. Giải nén vào `C:\flutter`
3. Thêm `C:\flutter\bin` vào PATH:
   - Windows key → "Environment Variables"
   - Edit PATH → New → `C:\flutter\bin`
   - OK → Restart PowerShell

### Verify Installation
```powershell
flutter --version
flutter doctor
```

---

## 🔧 Step 2: Install Android Studio (15 phút)

### Download & Install
1. Download: https://developer.android.com/studio
2. Install với tất cả components
3. Mở Android Studio → More Actions → SDK Manager
4. Install:
   - ✅ Android SDK Platform-Tools
   - ✅ Android SDK Build-Tools
   - ✅ Android Emulator
   - ✅ Android SDK Platform (API 34)

### Setup Flutter in Android Studio
```
Android Studio → Plugins → Search "Flutter" → Install
Restart Android Studio
```

---

## 📱 Step 3: Create Xpiano Flutter Project

### Sau khi Flutter đã cài, chạy:
```powershell
# Di chuyển vào thư mục dự án
cd D:\Xpiano

# Tạo Flutter project
flutter create xpiano_mobile --org com.xpiano --platforms android,ios

# Di chuyển vào project
cd xpiano_mobile

# Chạy thử
flutter run -d windows
```

---

## ⚡ Quick Install (Run this after Flutter installed)

Copy toàn bộ commands này và paste vào PowerShell:

```powershell
# Go to project folder
cd D:\Xpiano

# Create Flutter project
flutter create xpiano_mobile --org com.xpiano --platforms android,ios

# Enter project
cd xpiano_mobile

# Add core dependencies
flutter pub add provider
flutter pub add http
flutter pub add firebase_core
flutter pub add firebase_auth
flutter pub add cloud_firestore
flutter pub add google_maps_flutter
flutter pub add flutter_webrtc
flutter pub add flutter_midi_command
flutter pub add just_audio
flutter pub add cached_network_image
flutter pub add shared_preferences

# Run doctor to check setup
flutter doctor

# Run app (Windows desktop first to test)
flutter run -d windows
```

---

## 🎯 Next Steps After Installation

1. **Tôi sẽ tạo project structure** 
2. **Setup Firebase**
3. **Tạo core services (MIDI, Audio, WebRTC)**
4. **Build first screen**

---

## ❗ Common Issues

### Issue: "flutter not found"
**Fix:** Restart PowerShell sau khi add PATH

### Issue: "Android licenses not accepted"
**Fix:** 
```powershell
flutter doctor --android-licenses
# Press Y for all
```

### Issue: "No devices found"
**Fix:** Enable Windows desktop
```powershell
flutter config --enable-windows-desktop
```

---

## 📞 Need Help?

Sau khi cài xong Flutter, gõ "done" và tôi sẽ:
1. Tạo project structure hoàn chỉnh
2. Setup Firebase
3. Tạo MIDI service
4. Build first screen để test

**Current Status:** Waiting for Flutter installation...
