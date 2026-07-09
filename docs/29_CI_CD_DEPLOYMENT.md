# CI/CD and Deployment

## Phase 1 local deployment

The system must run locally with:

```bash
docker compose up -d
cd apps/api
npm install
npx prisma migrate dev --name init
npm run seed
npm run start:dev
cd ../mobile
flutter pub get
flutter run
```

## Backend production deployment options

Potential targets:

- Azure App Service / Container Apps
- AWS ECS/Fargate
- OCI Container Instance / OKE
- On-prem Kubernetes
- VM with Docker Compose for demo only

## Database options

- PostgreSQL managed service
- Azure Database for PostgreSQL
- AWS RDS PostgreSQL
- OCI PostgreSQL if available
- Self-hosted PostgreSQL for demo only

## Redis options

- Managed Redis
- Container Redis for demo/local

## Mobile distribution options

- Apple App Store
- Google Play
- Enterprise/MDM distribution
- TestFlight
- Firebase App Distribution

Expo/client must decide distribution route.

## CI pipeline recommended steps

For GitHub Actions:

### Backend

```text
checkout
setup node
npm ci
prisma generate
npm run lint
npm test
npm run build
```

### Flutter

```text
checkout
setup flutter
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Environment separation

Each environment needs:

- API base URL
- database URL
- Redis URL
- JWT secrets
- Fusion mode/config
- push config
- CORS config

## Production security requirements

Before production:

- Use HTTPS.
- Use secret manager.
- Configure SSO.
- Disable demo login.
- Disable Swagger public exposure or protect it.
- Configure CORS to approved origins.
- Enable production logging/monitoring.
- Configure database backups.
- Configure incident response contacts.

## Store deployment checklist

### iOS

- Apple Developer account
- Bundle ID
- App icon
- App display name
- Signing certificates/profiles
- Privacy questionnaire
- TestFlight testers
- Push notification capability if used

### Android

- Google Play Developer account
- Application ID
- Signing key
- App icon
- Privacy/data safety form
- Internal testing track
- Push notification setup if used

## Demo deployment shortcut

For stakeholder demo, acceptable:

- Backend hosted on a simple cloud VM/container.
- PostgreSQL managed or container.
- Flutter web deployed for browser demo.
- Android APK installed directly.
- iOS TestFlight if Apple setup exists.

## Not included in Phase 1

- Final production cloud architecture approval
- Formal security review
- Penetration test
- App Store approval timing
- MDM policy setup
