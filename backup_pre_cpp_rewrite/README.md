# backup_pre_cpp_rewrite

This folder is a full backup of the original tracked repository content before the C++ rewrite path changes.

## What is included
- Flutter client source (`gsa_flutter/`)
- Backend source (`backend/`)
- Root build/config files (for example `README.md`, `LICENSE`, `.gitignore`)

## How to run the old version
1. Start backend:
   - `cd backend`
   - `cp .env.example .env`
   - `npm install`
   - `npm run dev`
2. Run Flutter app:
   - `cd gsa_flutter`
   - `flutter pub get`
   - `flutter run --dart-define=API_URL=http://10.0.2.2:3000/api --dart-define=SOCKET_URL=http://10.0.2.2:3001`
