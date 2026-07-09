# Handover Checklist

## Developer handover

- [ ] Root README has setup instructions.
- [ ] `.env.example` files exist.
- [ ] Docker Compose works.
- [ ] Prisma migration exists.
- [ ] Seed script works.
- [ ] Swagger works.
- [ ] Flutter app runs.
- [ ] Demo users documented.
- [ ] Known limitations documented.
- [ ] Oracle integration TODOs isolated in adapter.

## Code quality

- [ ] Backend modules are separated.
- [ ] DTO validation implemented.
- [ ] Guards implemented.
- [ ] No core business logic in controllers.
- [ ] No screen-level fake arrays in Flutter.
- [ ] Repositories/providers used.
- [ ] Reusable widgets used.
- [ ] No secrets committed.

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
