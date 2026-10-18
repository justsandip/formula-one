import 'package:flutter_test/flutter_test.dart';
import 'package:formula_one/app/app.dart';
import 'package:formula_one/counter/counter.dart';
import 'package:formula_one_repository/formula_one_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockFormulaOneRepository extends Mock implements FormulaOneRepository;

void main() {
  late FormulaOneRepository formulaOneRepository;

  setUp(() {
    formulaOneRepository = MockFormulaOneRepository();
  });

  group('App', () {
    testWidgets('renders AppView', (tester) async {
      await tester.pumpWidget(App(formulaOneRepository: formulaOneRepository));
      expect(find.byType(AppView), findsOneWidget);
    });
  });

  group('AppView', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(App(formulaOneRepository: formulaOneRepository));
      expect(find.byType(CounterPage), findsOneWidget);
    });
  });
}
