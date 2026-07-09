# Observability and Support

## Goals

The system must be diagnosable during demos and later production.

## Backend logging

Log:

- request method/path/status/duration
- trace ID
- user ID/email if authenticated
- business action
- error code

Do not log:

- passwords
- JWT tokens
- Oracle tokens
- secrets

## Trace IDs

Every request gets a trace ID.

Backend response envelope includes:

```json
{
  "meta": {
    "traceId": "abc-123",
    "timestamp": "2026-07-09T12:00:00.000Z"
  }
}
```

Flutter should optionally show trace ID in debug error details.

## Health endpoint

`GET /health`

Must check:

- API process status
- database connectivity
- Redis connectivity if enabled
- Fusion mode

Response:

```json
{
  "data": {
    "status": "ok",
    "database": "ok",
    "redis": "ok",
    "fusionMode": "mock"
  }
}
```

## Metrics to track later

- Login success/failure count
- Notification publish count
- Notification read rate
- Access request submission count
- Approval completion time
- Fusion provisioning success/failure
- API latency p50/p95/p99
- Error rate

## Audit vs logs

Audit logs are business/security records.

Application logs are operational diagnostics.

Do not confuse them.

## Production monitoring options

Depending on deployment:

- Azure Application Insights
- AWS CloudWatch
- OCI Logging/Monitoring
- Grafana/Prometheus
- Sentry for Flutter errors

## Support workflow

When user reports issue:

1. Ask for approximate time.
2. Ask for action they attempted.
3. Find trace ID if visible.
4. Search backend logs.
5. Search audit logs if business/security action.
6. Reproduce with same role.

## Flutter crash/error reporting

Not required in Phase 1, but architecture should allow adding Sentry/Firebase Crashlytics.
