part of 'results_bloc.dart';

enum ResultsStatus { initial, loading, success, empty, failure }

final class ResultsState extends Equatable {
  const new({
    this.status = ResultsStatus.initial,
    this.raceResults,
    this.round,
    this.failure,
  });

  final ResultsStatus status;
  final RaceResults? raceResults;
  final int? round;
  final FormulaOneApiFailure? failure;

  @override
  List<Object?> get props => [status, raceResults, round, failure];
}
