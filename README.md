# GSA – Global Students Association

A dark-themed, Discord-inspired student app with chat (public/private), Q&A, and exams.

## 📦 Version Snapshots (previous + cpp)

Two side-by-side snapshots are available in this repository:

- `GSA_previous/` (restored pre-C++ state from commit `d1e2016`)
- `GSA_cpp/` (current C++-hybrid main snapshot from commit `638f12b`)

See [CODE_VERSIONS.md](CODE_VERSIONS.md) for details.

| Layer | Description |
|-------|-------------|
| `gsa_flutter/` | Flutter client (Dart + C++ native core) |
| `backend/` | Node.js / Express / Socket.io API (in-memory store) |
| `gsa_flutter/native/core` | C++20 domain logic (validation, exam rules, scoring) |
| `gsa_flutter/native/platform/android` | Android JNI bridge for the C++ core |

---

## 📱 Build & Install APK (Beginner Guide)

> **New here?** See **[docs/BUILD_APK.md](docs/BUILD_APK.md)** for a full, step-by-step
> guide to build a debug APK and install it on your phone or an emulator.

**TL;DR (experienced Flutter developers):**

```bash
# 1. Start the backend
cd backend && npm install && npm run dev

# 2. Scaffold Android platform files (one-time only)
cd gsa_flutter && flutter create .

# 3. Install dependencies
flutter pub get

# 4. Build debug APK
flutter build apk --debug \
  --dart-define=API_URL=http://10.0.2.2:3000/api \
  --dart-define=SOCKET_URL=http://10.0.2.2:3001
# APK → gsa_flutter/build/app/outputs/flutter-apk/app-debug.apk

# 5. Install on connected Android device
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Or run directly on an emulator / connected device
flutter run \
  --dart-define=API_URL=http://10.0.2.2:3000/api \
  --dart-define=SOCKET_URL=http://10.0.2.2:3001
```

> On a **real phone** replace `10.0.2.2` with your computer's LAN IP (e.g. `192.168.1.10`).

---

## Quick start

### Backend
```bash
cd backend
cp .env.example .env   # edit JWT_SECRET if desired
npm install
npm run dev            # API on port 3000, Socket.io on port 3001
```

### Flutter app
```bash
cd gsa_flutter
flutter create .       # scaffold android/ once (not committed to git)
flutter pub get
flutter run \
  --dart-define=API_URL=http://10.0.2.2:3000/api \
  --dart-define=SOCKET_URL=http://10.0.2.2:3001
```

---

## Structure

```
gsa_flutter/
  lib/              Dart source (screens, services, providers, theme, widgets)
  native/
    core/           C++20 business logic (libgsa_core)
    platform/
      android/      JNI bridge for Android
pubspec.yaml        Flutter package manifest
backend/            Express API + Socket.io server
docs/
  BUILD_APK.md      Step-by-step APK build & install guide
```

---

## C++ native core

The app has an optional C++ native library. If the `.so` is absent, every call
falls back to equivalent Dart code — **the app works without it**.

Build and test the core locally:

```bash
cd gsa_flutter/native
cmake -S . -B build && cmake --build build
# Run unit tests
g++ -std=c++20 -I core/include core/src/gsa_core.cpp core/tests/gsa_core_tests.cpp \
    -o /tmp/gsa_core_tests && /tmp/gsa_core_tests
```

To include `libgsa_core.so` in the APK, see the **NDK integration** section in
[docs/BUILD_APK.md](docs/BUILD_APK.md#10-optional-enable-c-native-library-advanced).

---

## Path to Play Store (checklist)

1. Run `flutter create .` and add NDK + CMake config to `android/app/build.gradle`
   to bundle `libgsa_core.so`.
2. Set final `applicationId` and semantic `version` in `pubspec.yaml` /
   `android/app/build.gradle`.
3. Generate a signing key and configure `key.properties` (see
   [docs/BUILD_APK.md](docs/BUILD_APK.md#11-signing-for-play-store)).
4. Deploy backend to a public URL; update `API_URL` / `SOCKET_URL`.
5. Replace default Flutter icons with the GSA logo; add to `pubspec.yaml` assets.
6. Write a privacy policy and link it in the Play Console.
7. Fill the Play Data Safety form (network, auth tokens, chat data).
8. Run a full regression: login, chat, private chat, Q&A, exams.

---

## Notes

- **Persistence:** backend uses in-memory storage; swap in MongoDB/SQL for production.
- **Auth:** anonymous JWT; `verified` flag toggled client-side (demo only).
- **Exams:** sample MC/TF exam with auto-grading included.
- **Chat:** global and private rooms via Socket.io.
