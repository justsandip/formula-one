import 'package:api_client/api_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formula_one/l10n/l10n.dart';
import 'package:formula_one/results/results.dart';
import 'package:formula_one/schedule/schedule.dart';
import 'package:formula_one/widgets/widgets.dart';
import 'package:formula_one_repository/formula_one_repository.dart';
import 'package:material_ui/material_ui.dart';

part 'results_success.dart';
part 'results_top_bar.dart';
part 'round_picker_sheet.dart';

class ResultsPage extends StatelessWidget {
  const new({this.round, super.key});

  /// Round to show, or null for the most recent race with results.
  final int? round;

  static Route<void> route({required int round}) {
    return MaterialPageRoute<void>(builder: (_) => ResultsPage(round: round));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ResultsBloc>(
      create: (context) => ResultsBloc(
        formulaOneRepository: context.read<FormulaOneRepository>(),
      )..add(ResultsRequested(round: round)),
      child: const ResultsView(),
    );
  }
}

class ResultsView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ResultsBloc, ResultsState>(
          builder: (context, state) {
            return Column(
              children: [
                _ResultsTopBar(state: state),
                Expanded(child: _body(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ResultsState state) {
    final raceResults = state.raceResults;

    switch (state.status) {
      case ResultsStatus.initial:
      case ResultsStatus.loading:
      case ResultsStatus.success:
        if (raceResults == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return ResultsSuccess(raceResults: raceResults);
      case ResultsStatus.empty:
        return Center(
          child: Text(
            context.l10n.resultsEmpty.toUpperCase(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        );
      case ResultsStatus.failure:
        return FormulaOneFailureView(
          failure: state.failure,
          onRetry: () => context.read<ResultsBloc>().add(
            ResultsRequested(round: state.round),
          ),
        );
    }
  }
}
