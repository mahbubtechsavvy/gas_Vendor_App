# 🚀 Quick Start Guide - Gas Vendor App

## Step 1: Enable Developer Mode (Windows)

A settings window should have opened. If not, run:
```powershell
start ms-settings:developers
```

**Enable "Developer Mode"** by toggling the switch to ON.

---

## Step 2: Update API Configuration

Edit `lib/config/api_config.dart`:

```dart
// Replace this with your PHP backend URL
static const String baseUrl = 'http://your-server-ip/gas_delivery/api/v1';

// For local testing:
// - Android Emulator: http://10.0.2.2/gas_delivery/api/v1
// - Real Device: http://192.168.1.XXX/gas_delivery/api/v1
```

---

## Step 3: Run the App

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Run on Android device/emulator
flutter run
```

---

## Step 4: Test the App

**Demo Credentials:**
- Mobile: `+8801700000002`
- Password: `vendor123`

**Or Register New Vendor:**
1. Click "Register" on  login screen
2. Fill all vendor details
3. Verify mobile with Firebase OTP
4. Login with credentials

---

## 🔧 Troubleshooting

### Error: "Developer Mode not enabled"
- Run `start ms-settings:developers`
- Toggle Developer Mode ON
- Restart your terminal

### Error: "Firebase not configured" 
- Ensure `android/app/google-services.json` exists ✅ (Already added!)
- Package name matches: `com.mahbub.vendorapp` ✅

### Error: "Unable to connect to server"
- Update `lib/config/api_config.dart` with your backend URL
- Ensure backend is running
- Check firewall settings

### OTP not received
- Verify Firebase Phone Authentication is enabled
- Check phone number format: `+880XXXXXXXXXX`
- Add test phone numbers in Firebase Console

---

## 📱 Building APK

```bash
# Debug APK (for testing)
flutter build apk --debug

# Release APK (for distribution)
flutter build apk --release

# Find APK at:
# build/app/outputs/flutter-apk/app-release.apk
```

---

## ✅ What's Working

- ✅ Firebase SMS OTP authentication
- ✅ Login / Registration / Forgot Password
- ✅ Dashboard with statistics
- ✅ Professional UI design
- ✅ Provider state management
- ✅ Complete architecture

## ⏳ What's Next

Build these screens to complete the app:
- Order management (accept/decline orders)
- Product management (add/edit/delete products)
- Sales analytics with charts
- Profile settings
- Notifications
- Prescription handling (for medical vendors)

Refer to `implementation_plan.md` for complete feature list!

---

**Ready to run!** 🎉
