# Build & Install the GSA APK — Beginner's Guide

This guide walks you through building a debug APK from source and installing it on
an Android phone **or** running it inside an emulator on your computer.

> **Skill level:** Beginner-friendly. Every command is explained.  
> **Time:** ~15–30 min on a fresh machine (mostly download time).

---

## 1. Prerequisites

Install the following tools before you start. All are free.

### 1-A. Flutter SDK (required)

Flutter is the framework the app is written in. It bundles everything needed to build
Android APKs — you do **not** need to install Android Studio separately (though it helps).

| OS | Download |
|----|---------|
| Windows | https://docs.flutter.dev/get-started/install/windows |
| macOS   | https://docs.flutter.dev/get-started/install/macos |
| Linux   | https://docs.flutter.dev/get-started/install/linux |

Follow the official guide for your OS. After installing, run:

```bash
flutter doctor
```

This command checks your environment. Aim for all green checkmarks in the
**Flutter**, **Android toolchain**, and **Android Studio** rows.

### 1-B. Java Development Kit (JDK)

Flutter's Android build needs JDK 17 (LTS). Download from:

- [Eclipse Temurin 17](https://adoptium.net/temurin/releases/?version=17) (recommended, free)
- OpenJDK 17 from your OS package manager:  
  `sudo apt install openjdk-17-jdk` (Debian/Ubuntu)  
  `brew install openjdk@17` (macOS with Homebrew)

Confirm with:

```bash
java -version   # should print openjdk 17.x.x
```

### 1-C. Android SDK (included with Android Studio)

The easiest way to get the Android SDK is to install **Android Studio**:

1. Download from https://developer.android.com/studio
2. Launch Android Studio → complete the Setup Wizard.
3. The wizard installs the Android SDK, build tools, and an emulator image automatically.

If you prefer the command-line tools only (no IDE), follow
https://developer.android.com/studio#command-tools.

**Minimum SDK versions required by this app:**

| Setting | Value |
|---------|-------|
| `minSdkVersion` | 21 (Android 5.0) |
| `compileSdkVersion` | 34 |
| `targetSdkVersion` | 34 |

After Android Studio is set up, run `flutter doctor` again and ensure the
Android toolchain row shows ✓.

---

## 2. Get the Source Code

```bash
git clone https://github.com/UnEngineerableFish52/GSA-GLOBAL-STUDENTS-ASSOCIATION.git
cd GSA-GLOBAL-STUDENTS-ASSOCIATION
```

---

## 3. Scaffold the Android Platform Files

The `android/` folder (which contains the Gradle build files) is **not committed** to the
repository — Flutter generates it from templates. You only need to do this **once**:

```bash
cd gsa_flutter
flutter create .
```

This creates `gsa_flutter/android/`, `gsa_flutter/ios/`, etc.

> If `flutter create .` asks about organization name, enter anything — e.g. `com.example`.  
> You can change the `applicationId` in
> `gsa_flutter/android/app/build.gradle` later.

---

## 4. Install Dependencies

Still inside `gsa_flutter/`:

```bash
flutter pub get
```

This downloads all Dart/Flutter packages listed in `pubspec.yaml`.

---

## 5. Build the Debug APK

A **debug APK** is the fastest way to test the app. It does not require a signing key.

```bash
# Still inside gsa_flutter/
flutter build apk --debug \
  --dart-define=API_URL=http://10.0.2.2:3000/api \
  --dart-define=SOCKET_URL=http://10.0.2.2:3001
```

> **What are those `--dart-define` flags?**  
> They tell the app where to find the backend.
> - `10.0.2.2` is the special address that lets the Android emulator reach your PC's
>   `localhost`.  
> - If you are on a **real phone**, replace `10.0.2.2` with your computer's LAN IP
>   (e.g. `192.168.1.10`). Find it with `ipconfig` (Windows) or `ip addr` / `ifconfig`
>   (macOS/Linux).

When the build finishes you will see:

```
✓  Built build/app/outputs/flutter-apk/app-debug.apk (XX.X MB)
```

The APK lives at:

```
gsa_flutter/build/app/outputs/flutter-apk/app-debug.apk
```

You can rename it for convenience:

```bash
cp build/app/outputs/flutter-apk/app-debug.apk build/app/outputs/flutter-apk/GSA-debug.apk
```

---

## 6. Install on an Android Phone (USB)

### 6-A. Enable USB Debugging on your phone

1. Go to **Settings → About phone**.
2. Tap **Build number** 7 times quickly → "Developer options" is now unlocked.
3. Go to **Settings → Developer options** → enable **USB debugging**.

### 6-B. Connect and install

1. Connect your phone to your PC with a USB cable.
2. On your phone, tap **Allow** when asked to trust the computer.
3. Verify the phone is detected:

```bash
adb devices
# Expected output:
# List of devices attached
# XXXXXXXXXX    device
```

> **`adb` not found?**  
> Add the Android platform-tools directory to your PATH.  
> Default locations:  
> - Windows: `C:\Users\<you>\AppData\Local\Android\Sdk\platform-tools`  
> - macOS/Linux: `~/Android/Sdk/platform-tools` or `~/Library/Android/sdk/platform-tools`

4. Install the APK:

```bash
adb install -r gsa_flutter/build/app/outputs/flutter-apk/app-debug.apk
```

The `-r` flag re-installs without uninstalling first (keeps your data).

5. The app will appear in your phone's app list as **GSA - Global Students Association**.

### 6-C. Alternative: Manual sideload (no USB cable required)

1. Copy the `.apk` file to your phone (via USB file transfer, Google Drive, email, etc.).
2. On the phone, open your file manager and tap the `.apk` file.
3. Android will ask to **Allow installs from this source** — enable it once.
4. Tap **Install**.

> Note: the backend server must be running and reachable from the phone's network.

---

## 7. Run on a Computer (Emulator)

No Android phone? Run the app in an emulator on your PC.

### 7-A. Create an emulator (via Android Studio)

1. Open Android Studio → **Device Manager** (the phone icon in the right toolbar).
2. Click **+ Create Virtual Device**.
3. Choose a device profile (e.g. **Pixel 6**) → click **Next**.
4. Download a system image for **API 34** (Android 14) → click **Next → Finish**.

### 7-B. Start the emulator and run the app

```bash
# Start the emulator from command line (or just launch it from Android Studio)
emulator -avd Pixel_6_API_34

# In a second terminal, inside gsa_flutter/:
flutter run \
  --dart-define=API_URL=http://10.0.2.2:3000/api \
  --dart-define=SOCKET_URL=http://10.0.2.2:3001
```

`flutter run` builds and installs in one step, then launches the app immediately.

### 7-C. Install a pre-built APK into the emulator

If you already built `app-debug.apk` and just want to install it:

```bash
adb -e install -r gsa_flutter/build/app/outputs/flutter-apk/app-debug.apk
# -e  targets the running emulator
```

---

## 8. Backend Setup (needed for the app to work)

The app requires the Node.js backend to be running. In a separate terminal:

```bash
cd backend
cp .env.example .env    # edit JWT_SECRET if you like
npm install
npm run dev             # starts API on port 3000, Socket.io on port 3001
```

The backend uses an **in-memory store** — data resets each time the server restarts.
This is fine for testing.

---

## 9. Build a Release APK (unsigned, for distribution testing)

A release APK is smaller and faster than a debug APK, but it must be **signed** before
it can be uploaded to the Play Store.

```bash
flutter build apk --release \
  --dart-define=API_URL=https://YOUR-BACKEND-URL/api \
  --dart-define=SOCKET_URL=https://YOUR-BACKEND-SOCKET-URL
```

Output: `gsa_flutter/build/app/outputs/flutter-apk/app-release.apk`

> **Unsigned release APK warning:** Android 7+ will refuse to install an unsigned APK
> directly. For local testing use the debug APK (step 5) or sign with a test key — see
> the Play Store section below.

---

## 10. Optional: Enable C++ Native Library (Advanced)

The app contains a C++ core (`gsa_flutter/native/`) that provides domain logic.
If the native library is **not** built, the app automatically falls back to
equivalent Dart code — **the app works either way**.

To include the native library in the APK (needed for Play Store release):

1. After running `flutter create .` (step 3), open
   `gsa_flutter/android/app/build.gradle`.

2. Inside the `android { ... }` block, add the following (adjust the ndkVersion to
   what you have installed in Android Studio):

```groovy
android {
    // ... existing settings ...

    ndkVersion "26.1.10909125"   // match the NDK installed in Android Studio

    externalNativeBuild {
        cmake {
            path "../../native/CMakeLists.txt"
            version "3.22.1"
        }
    }

    defaultConfig {
        // ... existing settings ...
        externalNativeBuild {
            cmake {
                cppFlags "-std=c++20"
                abiFilters "arm64-v8a", "x86_64"
            }
        }
    }
}
```

3. Install the NDK in Android Studio:
   **SDK Manager → SDK Tools → NDK (Side by side)** → check it → Apply.

4. Run `flutter build apk --release ...` as usual.

---

## 11. Signing for Play Store

You need a **signing key** to publish on Google Play (or to install a release APK on
most modern Android phones).

```bash
# Generate a keystore (one-time, keep it safe!)
keytool -genkey -v \
  -keystore upload-keystore.jks \
  -alias upload \
  -keyalg RSA -keysize 2048 \
  -validity 10000

# Create gsa_flutter/android/key.properties (NEVER commit this file)
cat > gsa_flutter/android/key.properties <<EOF
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks
EOF
```

Then update `gsa_flutter/android/app/build.gradle` to reference `key.properties`
using the standard Flutter signing configuration (see
https://docs.flutter.dev/deployment/android#signing-the-app).

---

## 12. Play Store Readiness Summary

| Item | Status | Notes |
|------|--------|-------|
| App builds & runs | ✅ Functional (with Dart fallbacks) | Core features complete |
| Login / Guest mode | ✅ Working | Anonymous JWT auth |
| Global chat | ✅ Working | Socket.io |
| Private chat | ✅ Working | Socket.io |
| Q&A (questions) | ✅ Working | CRUD + seeded data |
| Exams + grading | ✅ Working | MC/TF + auto-score |
| android/ scaffolding | ⚠️ Not committed | Run `flutter create .` once |
| App icons | ⚠️ Default Flutter icon | Replace with GSA/neon logo |
| Signing key | ❌ Missing | Required for Play Store upload |
| Release backend | ❌ Not set up | In-memory only; needs real DB |
| Privacy policy URL | ❌ Missing | Play Store requires this |
| Play Data Safety form | ❌ Not filled | Network, auth data must be declared |
| Versioning (versionName) | ⚠️ `1.0.0+1` | Update as needed in `pubspec.yaml` |
| NDK / C++ `.so` in APK | ⚠️ Optional | App works without it (Dart fallback) |

**Bottom line for a beginner project:** The app is very close to fully functional.
The main blockers before Play Store upload are: app signing, a publicly hosted
backend, app icons, and the privacy policy.
