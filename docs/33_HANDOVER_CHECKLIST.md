# Handover Checklist

## Developer handover

- [x] Root README has setup instructions.
- [x] `.env.example` files exist.
- [x] Docker Compose works.
- [x] Prisma migration exists.
- [x] Seed script works.
- [x] Swagger works.
- [x] Flutter app runs. (code-ready + automated coverage; interactive device sign-off optional / external)
- [x] Demo users documented.
- [x] Known limitations documented.
- [x] Oracle integration TODOs isolated in adapter.

## Code quality

- [x] Backend modules are separated.
- [x] DTO validation implemented.
- [x] Guards implemented.
- [x] No core business logic in controllers.
- [x] No screen-level fake arrays in Flutter.
- [x] Repositories/providers used.
- [x] Reusable widgets used.
- [x] No secrets committed.

## Business handover

Provide:

- Demo script
- User roles
- Workflow diagram
- List of assumptions
- List of required Oracle details for Phase 2
- Pending decisions

## Phase 2 inputs needed from client

- Oracle Fusion tenant URL
- Identity provider details
- OAuth/client credentials
- Fusion/OIC endpoints
- Role catalog ownership
- Manager hierarchy source
- Security admin assignment policy
- Push notification distribution method
- Deployment environment
- App publishing route

## Final package to client

Include:

- Source code repo
- `/docs`
- Demo credentials
- Setup guide
- API documentation link
- Demo video/screenshots if available
- Phase 2 integration plan
