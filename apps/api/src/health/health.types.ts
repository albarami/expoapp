export interface HealthCheckResult {
  status: 'ok' | 'degraded';
  database: 'ok' | 'error';
  redis: 'ok' | 'error' | 'disabled';
  fusionMode: string;
}
