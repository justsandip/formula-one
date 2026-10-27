import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formula_one/l10n/l10n.dart';
import 'package:formula_one/schedule/schedule.dart';
import 'package:formula_one/standings/standings.dart';
import 'package:formula_one/theme/theme.dart';
import 'package:formula_one_repository/formula_one_repository.dart';
import 'package:material_ui/material_ui.dart';

extension PumpApp on WidgetTester {
  /// Pumps [widget] inside a themed [MaterialApp].
  ///
  /// Uses the real color scheme but the default text theme, so widget tests
  /// never load Google Fonts. Providers sit above the app so pushed routes
  /// can read them too.
  Future<void> pumpApp(
    Widget widget, {
    FormulaOneRepository? formulaOneRepository,
    ScheduleBloc? scheduleBloc,
    StandingsBloc? standingsBloc,
  }) {
    Widget app = MaterialApp(
      theme: ThemeData(colorScheme: const FormulaOneTheme().colorScheme),
      home: widget,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
    if (scheduleBloc != null) {
      app = BlocProvider<ScheduleBloc>.value(value: scheduleBloc, child: app);
    }
    if (standingsBloc != null) {
      app = BlocProvider<StandingsBloc>.value(value: standingsBloc, child: app);
    }
    if (formulaOneRepository != null) {
      app = RepositoryProvider<FormulaOneRepository>.value(
        value: formulaOneRepository,
        child: app,
      );
    }
    return pumpWidget(app);
  }
}
