import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:formula_one_repository/formula_one_repository.dart';

part 'standings_event.dart';
part 'standings_state.dart';

class StandingsBloc extends Bloc<StandingsEvent, StandingsState> {
  new({required this._formulaOneRepository}) : super(const StandingsState()) {
    on<StandingsRequested>(_onStandingsRequested, transformer: restartable());
  }

  final FormulaOneRepository _formulaOneRepository;

  Future<void> _onStandingsRequested(
    StandingsRequested event,
    Emitter<StandingsState> emit,
  ) async {
    final season = event.season;
    // Keep the old lists while the same season reloads, drop them otherwise.
    final sameSeason = state.season == season;
    final drivers = sameSeason ? state.drivers : const <DriverStanding>[];
    final constructors = sameSeason
        ? state.constructors
        : const <ConstructorStanding>[];

    emit(
      StandingsState(
        status: StandingsStatus.loading,
        drivers: drivers,
        constructors: constructors,
        season: season,
      ),
    );
    try {
      // List form of Future.wait rethrows the original failure; the record
      // form would wrap it in a ParallelWaitError.
      final results = await Future.wait<Object>([
        _formulaOneRepository.getDriverStandings(season: season),
        _formulaOneRepository.getConstructorStandings(season: season),
      ]);
      emit(
        StandingsState(
          status: StandingsStatus.success,
          drivers: results[0] as List<DriverStanding>,
          constructors: results[1] as List<ConstructorStanding>,
          season: season,
        ),
      );
    } on FormulaOneApiFailure catch (failure) {
      emit(
        StandingsState(
          status: StandingsStatus.failure,
          drivers: drivers,
          constructors: constructors,
          season: season,
          failure: failure,
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        StandingsState(
          status: StandingsStatus.failure,
          drivers: drivers,
          constructors: constructors,
          season: season,
          failure: FormulaOneUnknownFailure(
            'Unexpected error loading the standings',
            cause: error,
          ),
        ),
      );
    }
  }
}
