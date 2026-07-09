import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expoapp_mobile/app/theme.dart';
import 'package:expoapp_mobile/l10n/app_localizations.dart';
import 'package:expoapp_mobile/shared/widgets/widgets.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('EmptyState and ErrorState render actions', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      _wrap(
        ErrorState(
          title: 'Error',
          message: 'Failed',
          onRetry: () => retried = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Error'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);

    await tester.pumpWidget(
      _wrap(
        const EmptyState(
          title: 'Empty',
          message: 'Nothing here',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Empty'), findsOneWidget);
  });

  testWidgets('StatusChip and PriorityChip show localized labels',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        const Row(
          children: [
            StatusChip(status: RequestStatus.completed),
            PriorityChip(priority: NotificationPriority.high),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
  });

  testWidgets('Arabic EmptyState uses RTL-friendly text', (tester) async {
    await tester.pumpWidget(
      _wrap(
        Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            return EmptyState(
              title: l10n.noNotifications,
              message: l10n.noNotificationsMessage,
            );
          },
        ),
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('لا توجد إشعارات حتى الآن'), findsOneWidget);
  });
}
