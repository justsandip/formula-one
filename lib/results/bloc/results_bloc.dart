import 'package:api_client/api_client.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formula_one_repository/formula_one_repository.dart';

part 'results_event.dart';
part 'results_state.dart';

class ResultsBloc extends Bloc<ResultsEvent, ResultsState> {
  new({required this._formulaOneRepository}) : super(const ResultsState()) {
    on<ResultsRequested>(_onResultsRequested, transformer: restartable());
  }

  final FormulaOneRepository _formulaOneRepository;

  Future<void> _onResultsRequested(
    ResultsRequested event,
    Emitter<ResultsState> emit,
  ) async {
    final round = event.round;
    // Keep the old results while the same round reloads, drop them otherwise.
    final raceResults = state.round == round ? state.raceResults : null;

    emit(
      ResultsState(
        status: ResultsStatus.loading,
        raceResults: raceResults,
        round: round,
      ),
    );
    try {
      final loaded = round == null
          ? await _formulaOneRepository.getLatestRaceResults()
          : await _formulaOneRepository.getRaceResults(round: round);

      emit(
        loaded == null
            ? ResultsState(status: ResultsStatus.empty, round: round)
            : ResultsState(
                status: ResultsStatus.success,
                raceResults: loaded,
                round: round,
              ),
      );
    } on FormulaOneApiFailure catch (failure) {
      emit(
        ResultsState(
          status: ResultsStatus.failure,
          raceResults: raceResults,
          round: round,
          failure: failure,
        ),
      );
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        ResultsState(
          status: ResultsStatus.failure,
          raceResults: raceResults,
          round: round,
          failure: FormulaOneUnknownFailure(
            'Unexpected error loading the results',
            cause: error,
          ),
        ),
      );
    }
  }
}
