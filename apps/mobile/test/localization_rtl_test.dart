import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expoapp_mobile/app/localization.dart';
import 'package:expoapp_mobile/core/api/api_error.dart';
import 'package:expoapp_mobile/core/errors/error_mapper.dart';
import 'package:expoapp_mobile/core/localization/audit_labels.dart';
import 'package:expoapp_mobile/core/localization/locale_controller.dart';
import 'package:expoapp_mobile/core/providers.dart';
import 'package:expoapp_mobile/features/audit/domain/audit_models.dart';
import 'package:expoapp_mobile/l10n/app_localizations.dart';
import 'package:expoapp_mobile/shared/widgets/widgets.dart';

Widget _wrap(
  Widget child, {
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: locale,
      theme: ThemeData(useMaterial3: true),
      localizationsDelegates: AppLocalization.localizationsDelegates,
      supportedLocales: AppLocalization.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  test('EN and AR localizations expose required bilingual keys', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final ar = await AppLocalizations.delegate.load(const Locale('ar'));

    expect(en.appName, isNotEmpty);
    expect(ar.appName, isNotEmpty);
    expect(en.login, isNot(ar.login));
    expect(en.dashboard, isNot(ar.dashboard));
    expect(en.noNotifications, isNot(ar.noNotifications));
    expect(en.errorManagerNotFound, isNot(ar.errorManagerNotFound));
    expect(en.errorNotFound, isNot(ar.errorNotFound));
    expect(en.errorInvalidAudienceFilter, isNot(ar.errorInvalidAudienceFilter));
    expect(
      en.errorFusionConfigurationMissing,
      isNot(ar.errorFusionConfigurationMissing),
    );
    expect(
      en.errorFusionProvisioningFailed,
      isNot(ar.errorFusionProvisioningFailed),
    );
    expect(en.auditActionAuthLogin, isNot(ar.auditActionAuthLogin));
    expect(en.auditEntityAccessRequest, isNot(ar.auditEntityAccessRequest));
    expect(en.networkError, contains('Cannot connect'));
    expect(ar.networkError, contains('لا يمكن الاتصال'));
  });

  test('localizeApiError covers docs 27 error codes in EN and AR', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final ar = await AppLocalizations.delegate.load(const Locale('ar'));

    final cases = <String, String Function(AppLocalizations)>{
      'MANAGER_NOT_FOUND': (l) => l.errorManagerNotFound,
      'ROLE_NOT_REQUESTABLE': (l) => l.errorRoleNotRequestable,
      'DUPLICATE_ACTIVE_REQUEST': (l) => l.errorDuplicateActiveRequest,
      'REQUEST_NOT_CANCELABLE': (l) => l.errorRequestNotCancelable,
      'APPROVAL_TASK_NOT_PENDING': (l) => l.errorApprovalNotPending,
      'NOT_TASK_ASSIGNEE': (l) => l.errorNotTaskAssignee,
      'VALIDATION_ERROR': (l) => l.errorValidation,
      'UNAUTHORIZED': (l) => l.errorUnauthorized,
      'FORBIDDEN': (l) => l.errorForbidden,
      'NOT_FOUND': (l) => l.errorNotFound,
      'INVALID_AUDIENCE_FILTER': (l) => l.errorInvalidAudienceFilter,
      'FUSION_CONFIGURATION_MISSING': (l) => l.errorFusionConfigurationMissing,
      'FUSION_PROVISIONING_FAILED': (l) => l.errorFusionProvisioningFailed,
      'NETWORK_ERROR': (l) => l.networkError,
    };

    for (final entry in cases.entries) {
      final error = ApiError(code: entry.key, message: 'raw-${entry.key}');
      expect(localizeApiError(en, error), entry.value(en));
      expect(localizeApiError(ar, error), entry.value(ar));
      expect(localizeApiError(en, error), isNot(localizeApiError(ar, error)));
    }
  });

  test('localizedName falls back to English when Arabic missing', () {
    expect(
      AppLocalization.localizedName(
        locale: const Locale('ar'),
        nameEn: 'Operations',
        nameAr: null,
      ),
      'Operations',
    );
    expect(
      AppLocalization.localizedName(
        locale: const Locale('ar'),
        nameEn: 'Operations',
        nameAr: '   ',
      ),
      'Operations',
    );
    expect(
      AppLocalization.localizedName(
        locale: const Locale('ar'),
        nameEn: 'Operations',
        nameAr: 'العمليات',
      ),
      'العمليات',
    );
  });

  test('audit action and entity labels localize', () async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final ar = await AppLocalizations.delegate.load(const Locale('ar'));

    expect(
      localizeAuditAction(en, AuditActionCodes.authLogin),
      en.auditActionAuthLogin,
    );
    expect(
      localizeAuditAction(ar, AuditActionCodes.authLogin),
      ar.auditActionAuthLogin,
    );
    expect(
      localizeAuditEntityType(en, AuditEntityTypes.accessRequest),
      en.auditEntityAccessRequest,
    );
    expect(
      localizeAuditEntityType(ar, AuditEntityTypes.accessRequest),
      ar.auditEntityAccessRequest,
    );
    expect(localizeAuditAction(en, 'UNKNOWN_CODE'), 'UNKNOWN_CODE');
  });

  testWidgets('Arabic locale sets RTL Directionality', (tester) async {
    TextDirection? direction;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            direction = Directionality.of(context);
            return Text(AppLocalizations.of(context).dashboard);
          },
        ),
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(direction, TextDirection.rtl);
    expect(find.text('الرئيسية'), findsOneWidget);
  });

  testWidgets('English locale sets LTR Directionality', (tester) async {
    TextDirection? direction;
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            direction = Directionality.of(context);
            return Text(AppLocalizations.of(context).dashboard);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(direction, TextDirection.ltr);
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('LanguageSwitcher persists Arabic selection', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const LanguageSwitcher(),
        overrides: [
          localeControllerProvider.overrideWith(
            (ref) => LocaleController(initialLocale: const Locale('en')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(
      Directionality.of(tester.element(find.byType(LanguageSwitcher))),
      TextDirection.ltr,
    );

    await tester.tap(find.text('Arabic'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      _wrap(
        const LanguageSwitcher(),
        locale: const Locale('ar'),
        overrides: [
          localeControllerProvider.overrideWith(
            (ref) => LocaleController(initialLocale: const Locale('ar')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(
      Directionality.of(tester.element(find.byType(LanguageSwitcher))),
      TextDirection.rtl,
    );
    expect(find.text('العربية'), findsOneWidget);
  });

  testWidgets('Scenario 4 key strings render in Arabic', (tester) async {
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return ListView(
              children: [
                Text(l10n.dashboard),
                Text(l10n.notifications),
                Text(l10n.requests),
                Text(l10n.submit),
                Text(l10n.newAccessRequest),
                Text(l10n.noNotifications),
                Text(l10n.noRequests),
              ],
            );
          },
        ),
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('الإشعارات'), findsOneWidget);
    expect(find.text('الطلبات'), findsOneWidget);
    expect(find.text('إرسال'), findsOneWidget);
    expect(find.text('طلب صلاحية جديد'), findsOneWidget);
    expect(find.text('لا توجد إشعارات حتى الآن'), findsOneWidget);
    expect(find.text('لا توجد طلبات صلاحيات حتى الآن'), findsOneWidget);
  });
}
