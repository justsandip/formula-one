part of 'standings_bloc.dart';

/// Loading status of the standings.
enum StandingsStatus { initial, loading, success, failure }

final class StandingsState extends Equatable {
  const new({
    this.status = StandingsStatus.initial,
    this.drivers = const [],
    this.constructors = const [],
    this.season = 'current',
    this.failure,
  });

  final StandingsStatus status;
  final List<DriverStanding> drivers;
  final List<ConstructorStanding> constructors;
  final String season;
  final FormulaOneApiFailure? failure;

  @override
  List<Object?> get props => [status, drivers, constructors, season, failure];
}
