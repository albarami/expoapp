# ExpoApp Mobile

Flutter client for ExpoApp (iOS / Android / Web).

## Stack

- Flutter + Material 3
- Riverpod, GoRouter, Dio, flutter_secure_storage
- EN/AR localization (`lib/l10n`)

## Run

```bash
cd apps/mobile
flutter pub get
flutter run
```

API base URL defaults to Android emulator host (`http://10.0.2.2:3000/api/v1`).
Override with `--dart-define=API_BASE_URL=http://localhost:3000/api/v1` for iOS simulator / web / desktop.

See `.env.example` for documented defines.

## Validate

```bash
flutter analyze
flutter test
```
