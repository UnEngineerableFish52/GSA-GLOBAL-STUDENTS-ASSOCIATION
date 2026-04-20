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

## Structure
- `gsa_flutter/lib` – config, services (Dio, Socket.io), provider, theme, widgets, screens (Login, Dashboard, Questions, Private, Exams)
- `backend` – Express routes (auth, questions, exams, private-chats), Socket.io events (global/private), middleware, in-memory seed data

## Notes
- Assets: Flutter uses default icons; replace with your neon hex "M" when ready and add to `pubspec.yaml` if you include custom assets.
- Persistence: backend uses in-memory storage for quick demos; swap in Mongo/SQL later.
- Auth: anonymous JWT issuance; verified flag toggled client-side for now.
- Exams: includes sample MC/TF exam and auto-grading.
- Chat: global and private room messaging via Socket.io.