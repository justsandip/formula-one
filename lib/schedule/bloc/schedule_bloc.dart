import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:formula_one_repository/formula_one_repository.dart';
import 'package:meta/meta.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  new({required this._formulaOneRepository}) : super(const ScheduleState()) {
    on<ScheduleRequested>(_onScheduleRequested, transformer: restartable());
  }

  final FormulaOneRepository _formulaOneRepository;

  Future<void> _onScheduleRequested(
    ScheduleRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    final season = event.season;
    // Keep the old list while the same season reloads, drop it otherwise.
    final races = state.season == season ? state.races : const <Race>[];

    emit(
      ScheduleState(
        status: ScheduleStatus.loading,
        races: races,
        season: season,
      ),
    );
    try {
      final loaded = await _formulaOneRepository.getRaces(season: season);
      emit(
        ScheduleState(
          status: ScheduleStatus.success,
          races: loaded,
          season: season,
        ),
      );
    } on FormulaOneApiFailure catch (failure) {
      emit(
        ScheduleState(
          status: ScheduleStatus.failure,
          races: races,
          season: season,
          failure: failure,
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        ScheduleState(
          status: ScheduleStatus.failure,
          races: races,
          season: season,
          failure: FormulaOneUnknownFailure(
            'Unexpected error loading the schedule',
            cause: error,
          ),
        ),
      );
    }
  }
}
