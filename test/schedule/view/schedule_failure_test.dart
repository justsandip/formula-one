import 'package:api_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formula_one/schedule/schedule.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/helpers.dart';

void main() {
  group('ScheduleFailure', () {
    const offline = 'You are offline. Check your connection and try again.';
    const generic = 'Something went wrong. Please try again.';

    Future<void> pumpFailure(
      WidgetTester tester, {
      FormulaOneApiFailure? failure,
      VoidCallback? onRetry,
    }) {
      return tester.pumpApp(
        Scaffold(
          body: ScheduleFailure(failure: failure, onRetry: onRetry ?? () {}),
        ),
      );
    }

    testWidgets('shows the offline message for a network failure',
        (tester) async {
      await pumpFailure(
        tester,
        failure: const FormulaOneNetworkFailure('offline'),
      );

      expect(find.text(offline), findsOneWidget);
    });

    testWidgets('shows the generic message for other failures', (tester) async {
      await pumpFailure(
        tester,
        failure: const FormulaOneHttpFailure('boom', statusCode: 500),
      );

      expect(find.text(generic), findsOneWidget);
    });

    testWidgets('shows the generic message when there is no failure',
        (tester) async {
      await pumpFailure(tester);

      expect(find.text(generic), findsOneWidget);
    });

    testWidgets('calls onRetry when Retry is tapped', (tester) async {
      var retries = 0;
      await pumpFailure(tester, onRetry: () => retries++);

      await tester.tap(find.text('Retry'));

      expect(retries, 1);
    });
  });
}
