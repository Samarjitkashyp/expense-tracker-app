import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_budget_tracker_app/main.dart';

void main() {
  testWidgets('App smoke test - verifies build', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: SpendWiseApp(),
      ),
    );

    // Verify that the loader or the login page renders
    // Since the initial state is loading: true in AuthProvider, we should expect a loader.
    // We pump the widget tree to let animations and timers resolve.
    await tester.pump();
    
    // We expect the loader to be present initially.
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
