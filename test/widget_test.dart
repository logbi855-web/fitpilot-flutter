import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app_flutter/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FitPilotApp()));
    await tester.pump();
    // App should render without throwing
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
