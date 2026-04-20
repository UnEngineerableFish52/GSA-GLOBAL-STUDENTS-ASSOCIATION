### GSA – Global Students Association

A dark-themed, Discord-inspired student app with chat (public/private), Q&A, and exams. This repo includes:
- `gsa_flutter/`: Flutter client
- `backend/`: Node.js/Express/Socket.io API (in-memory store for quick start)
- `LICENSE`

## Quick start

### Backend
```
cd backend
cp .env.example .env   # edit JWT_SECRET if desired
npm install
npm run dev            # starts API+Socket on PORT/SOCKET_PORT (default 3000/3001)
```

### Flutter app
```
cd gsa_flutter
flutter pub get
flutter run --dart-define=API_URL=http://10.0.2.2:3000/api --dart-define=SOCKET_URL=http://10.0.2.2:3001
# use your LAN IP instead of 10.0.2.2 on a real device
```

### Release APK
```
flutter build apk --release \
  --dart-define=API_URL=https://your.api/api \
  --dart-define=SOCKET_URL=https://your.socket
```

### Final touch: generate `GSA.apk` from this repo
If your local clone does not yet contain `gsa_flutter/android`, scaffold platform files first, then build:

```bash
cd gsa_flutter
flutter create .                         # creates android/ios/linux/... if missing
flutter pub get
flutter build apk --release \
  --dart-define=API_URL=https://your.api/api \
  --dart-define=SOCKET_URL=https://your.socket
cp build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/GSA.apk
```

Final APK path:
`gsa_flutter/build/app/outputs/flutter-apk/GSA.apk`

## Structure
- `gsa_flutter/lib` – config, services (Dio, Socket.io), provider, theme, widgets, screens (Login, Dashboard, Questions, Private, Exams)
- `backend` – Express routes (auth, questions, exams, private-chats), Socket.io events (global/private), middleware, in-memory seed data
- `gsa_flutter/native/core` – C++20 domain/business logic (validation, exam rules, formatting, parsing)
- `gsa_flutter/native/platform/android` – Android JNI bridge layer for native integration
- `gsa_flutter/lib/native` – Dart FFI bridge for calling C++ logic from Flutter UI
- `backup_pre_cpp_rewrite` – pre-rewrite backup of original tracked source/build files

## C++ rewrite strategy (Play Store realistic path)
This app is Flutter-based, so full UI rewrite into pure C++ is not practical for Play Store delivery in this repository shape.  
The implemented strategy is a **hybrid Flutter + C++ core**:
- Keep Flutter UI/navigation/screens as-is for velocity and compatibility
- Move domain logic to C++20 (`gsa_flutter/native/core`)
- Expose native behavior through Android bridge (`gsa_flutter/native/platform/android`) and Dart FFI (`gsa_flutter/lib/native`)

This is the safest path to preserve feature parity while improving native execution for core rules and keeping APK production feasible.

## Module port map (old → new)
- Input validation from screens (`questions`, `private chats`, `chat`) → `gsa_core::is_non_empty`, `gsa_core::normalize_members_csv`
- Exam submission gate logic (`exam_detail`) → `gsa_core::can_submit_exam`
- Shared timestamp formatting (`MessageBubble`) → `gsa_core::format_timestamp_hhmm`
- Score utility (new native utility for grading pipelines) → `gsa_core::score_percent`

## Native core build and test
Build C++ core/tests locally:
```bash
cd gsa_flutter/native
cmake -S . -B build
cmake --build build
g++ -std=c++20 -I core/include core/src/gsa_core.cpp core/tests/gsa_core_tests.cpp -o /tmp/gsa_core_tests
/tmp/gsa_core_tests
```

## Flutter side notes
- `lib/native/gsa_native_bridge.dart` loads `libgsa_core.so` when available.
- If native library is unavailable, it automatically falls back to equivalent Dart logic to keep behavior stable.

## Path to Play Store (release checklist)
1. Ensure `gsa_flutter/android` exists (`flutter create .` once) and add NDK+CMake integration to package `libgsa_core.so` inside release APK.
2. Set final applicationId/package name and semantic version in Android configs.
3. Configure signing (`upload-keystore.jks`, `key.properties`) and run release builds.
4. Enable/verify R8 rules for any JNI/FFI symbols used.
5. Finalize privacy policy + Play Data Safety entries (network calls, auth token handling, chat data).
6. Run regression on chat, Q&A, private chats, exams, login, and verified/guest gating across device matrix.
7. Set CI to run backend checks + native build + Flutter analyze/test + release APK assembly.

## Notes
- Assets: Flutter uses default icons; replace with your neon hex "M" when ready and add to `pubspec.yaml` if you include custom assets.
- Persistence: backend uses in-memory storage for quick demos; swap in Mongo/SQL later.
- Auth: anonymous JWT issuance; verified flag toggled client-side for now.
- Exams: includes sample MC/TF exam and auto-grading.
- Chat: global and private room messaging via Socket.io.
