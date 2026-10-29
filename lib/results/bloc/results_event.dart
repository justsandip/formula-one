part of 'results_bloc.dart';

sealed class ResultsEvent extends Equatable {
  const new();
}

final class ResultsRequested extends ResultsEvent {
  const new({this.round});
  final int? round;

  @override
  List<Object?> get props => [round];
}
