import 'package:flutter_test/flutter_test.dart';

import 'package:expoapp_mobile/core/api/api_error.dart';
import 'package:expoapp_mobile/core/auth/app_user.dart';
import 'package:expoapp_mobile/core/auth/session_controller.dart';
import 'package:expoapp_mobile/core/auth/token_storage.dart';
import 'package:expoapp_mobile/core/config/app_config.dart';
import 'package:expoapp_mobile/shared/models/paginated_response.dart';
import 'package:expoapp_mobile/shared/widgets/status_chip.dart';

void main() {
  group('ApiError', () {
    test('parses Nest error envelope', () {
      final error = ApiError.fromJson(
        {
          'error': {
            'code': 'VALIDATION_ERROR',
            'message': 'Invalid',
            'details': ['email'],
          },
          'meta': {'traceId': 'abc'},
        },
        statusCode: 400,
      );

      expect(error.code, 'VALIDATION_ERROR');
      expect(error.message, 'Invalid');
      expect(error.traceId, 'abc');
      expect(error.isValidation, isTrue);
      expect(error.statusCode, 400);
    });

    test('network factory', () {
      final error = ApiError.network();
      expect(error.isNetwork, isTrue);
    });
  });

  group('AppUser', () {
    test('parses role and permissions', () {
      final user = AppUser.fromJson({
        'id': '1',
        'email': 'admin@example.com',
        'displayName': 'Admin',
        'role': 'SYSTEM_ADMIN',
      });

      expect(user.role, AppRole.systemAdmin);
      expect(user.canViewAudit, isTrue);
      expect(user.canCreateNotification, isTrue);
      expect(user.toJson()['role'], 'SYSTEM_ADMIN');
    });
  });

  group('SessionController', () {
    test('restore without token is unauthenticated', () async {
      final storage = InMemoryTokenStorage();
      final controller = SessionController(storage);
      await Future<void>.delayed(Duration.zero);
      expect(controller.state.status, SessionStatus.unauthenticated);
    });

    test('setAuthenticated persists tokens and user', () async {
      final storage = InMemoryTokenStorage();
      final controller = SessionController(storage);
      await Future<void>.delayed(Duration.zero);

      await controller.setAuthenticated(
        user: const AppUser(
          id: 'u1',
          email: 'e@example.com',
          displayName: 'Emp',
          role: AppRole.employee,
        ),
        accessToken: 'token',
        refreshToken: 'refresh',
      );

      expect(controller.state.isAuthenticated, isTrue);
      expect(await storage.readAccessToken(), 'token');
      expect(await storage.readRefreshToken(), 'refresh');
      expect(await storage.readCurrentUserJson(), contains('e@example.com'));
    });
  });

  group('AppConfig', () {
    test('defaults match local Android emulator URL', () {
      final config = AppConfig.fromEnvironment();
      expect(config.apiBaseUrl, contains('api/v1'));
      expect(config.enableDemoLogin, isTrue);
    });
  });

  group('PaginatedResponse', () {
    test('maps items', () {
      final page = PaginatedResponse.fromJson(
        {
          'items': [
            {'id': '1'},
            {'id': '2'},
          ],
          'page': 1,
          'pageSize': 20,
          'total': 2,
        },
        (item) => item['id'] as String,
      );

      expect(page.items, ['1', '2']);
      expect(page.hasMore, isFalse);
    });
  });

  group('enums', () {
    test('RequestStatus and NotificationPriority parse', () {
      expect(
        RequestStatus.tryParse('MANAGER_PENDING'),
        RequestStatus.managerPending,
      );
      expect(
        NotificationPriority.tryParse('URGENT'),
        NotificationPriority.urgent,
      );
    });
  });
}
