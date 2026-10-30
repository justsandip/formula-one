import 'package:api_client/api_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formula_one/l10n/l10n.dart';
import 'package:formula_one/standings/bloc/standings_bloc.dart';
import 'package:formula_one/widgets/widgets.dart';
import 'package:formula_one_repository/formula_one_repository.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

part 'standings_success.dart';

class StandingsPage extends StatelessWidget {
  const new({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const StandingsPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StandingsBloc>(
      create: (context) => StandingsBloc(
        formulaOneRepository: context.read<FormulaOneRepository>(),
      )..add(const StandingsRequested()),
      child: const StandingsView(),
    );
  }
}

class StandingsView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<StandingsBloc, StandingsState>(
          builder: (context, state) {
            switch (state.status) {
              case StandingsStatus.initial:
              case StandingsStatus.loading:
                if (state.drivers.isEmpty && state.constructors.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return StandingsSuccess(
                  drivers: state.drivers,
                  constructors: state.constructors,
                );
              case StandingsStatus.success:
                return StandingsSuccess(
                  drivers: state.drivers,
                  constructors: state.constructors,
                );
              case StandingsStatus.failure:
                return FormulaOneFailureView(
                  failure: state.failure,
                  onRetry: () => context.read<StandingsBloc>().add(
                    StandingsRequested(season: state.season),
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}
