import 'dart:async';
import 'dart:math' as math;

import 'package:api_client/api_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formula_one/l10n/l10n.dart';
import 'package:formula_one/schedule/bloc/schedule_bloc.dart';
import 'package:formula_one_repository/formula_one_repository.dart';
import 'package:material_ui/material_ui.dart';

part 'next_race_card.dart';
part 'schedule_failure.dart';
part 'schedule_success.dart';

class SchedulePage extends StatelessWidget {
  const new({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const SchedulePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ScheduleBloc>(
      create: (context) => ScheduleBloc(
        formulaOneRepository: context.read<FormulaOneRepository>(),
      )..add(const ScheduleRequested()),
      child: const ScheduleView(),
    );
  }
}

class ScheduleView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ScheduleBloc, ScheduleState>(
          builder: (context, state) {
            switch (state.status) {
              case ScheduleStatus.initial:
              case ScheduleStatus.loading:
                if (state.races.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ScheduleSuccess(races: state.races);
              case ScheduleStatus.success:
                return ScheduleSuccess(races: state.races);
              case ScheduleStatus.failure:
                return ScheduleFailure(
                  failure: state.failure,
                  onRetry: () => context
                      .read<ScheduleBloc>()
                      .add(ScheduleRequested(season: state.season)),
                );
            }
          },
        ),
      ),
    );
  }
}
