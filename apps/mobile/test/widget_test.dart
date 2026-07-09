import 'package:flutter_test/flutter_test.dart';
import 'package:expoapp_mobile/main.dart';

void main() {
  testWidgets('ExpoApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpoApp());
    expect(find.text('ExpoApp'), findsOneWidget);
  });
}