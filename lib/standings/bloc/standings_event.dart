part of 'standings_bloc.dart';

sealed class StandingsEvent extends Equatable {
  const new();
}

final class StandingsRequested extends StandingsEvent {
  const new({this.season = 'current'});
  final String season;

  @override
  List<Object> get props => [season];
}
