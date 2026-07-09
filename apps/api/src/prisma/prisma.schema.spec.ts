import { existsSync } from 'node:fs';
import { join } from 'node:path';
import { Prisma } from '@prisma/client';

describe('Prisma schema (T-API-02)', () => {
  const modelNames = Prisma.dmmf.datamodel.models.map((model) => model.name);
  const enumNames = Prisma.dmmf.datamodel.enums.map((item) => item.name);

  it('exposes all required domain models', () => {
    expect(modelNames.sort()).toEqual(
      [
        'AccessRequest',
        'AccessRequestEvent',
        'AppSystem',
        'ApprovalTask',
        'AuditLog',
        'Department',
        'DeviceToken',
        'IntegrationOutbox',
        'Notification',
        'NotificationRecipient',
        'SecurityRoleCatalog',
        'User',
      ].sort(),
    );
  });

  it('exposes all required enums', () => {
    expect(enumNames.sort()).toEqual(
      [
        'AccessDuration',
        'AccessRequestStage',
        'AccessRequestStatus',
        'AccessUrgency',
        'ApprovalDecision',
        'ApprovalStage',
        'AudienceType',
        'NotificationPriority',
        'NotificationStatus',
        'OutboxStatus',
        'RiskLevel',
        'UserRole',
      ].sort(),
    );
  });

  it('wires User manager self-relation and department foreign key', () => {
    const user = Prisma.dmmf.datamodel.models.find(
      (model) => model.name === 'User',
    );
    const fieldNames = user?.fields.map((field) => field.name) ?? [];

    expect(fieldNames).toEqual(
      expect.arrayContaining([
        'departmentId',
        'managerId',
        'directReports',
        'passwordHash',
        'role',
        'email',
        'externalRef',
        'employeeNumber',
      ]),
    );
  });

  it('includes committed init migration', () => {
    const migrationsDir = join(__dirname, '..', '..', 'prisma', 'migrations');
    expect(existsSync(migrationsDir)).toBe(true);
    expect(existsSync(join(migrationsDir, 'migration_lock.toml'))).toBe(true);
  });
});
