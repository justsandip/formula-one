part of 'schedule_bloc.dart';

/// Loading status of the schedule.
enum ScheduleStatus { initial, loading, success, failure }

final class ScheduleState extends Equatable {
  const new({
    this.status = ScheduleStatus.initial,
    this.races = const [],
    this.season,
    this.failure,
  });

  /// Current loading status.
  final ScheduleStatus status;

  /// Races of [season]. Kept while the same season reloads.
  final List<Race> races;

  /// Selected season, or null for the current season.
  final int? season;

  /// Why the last load failed, if it did.
  final FormulaOneApiFailure? failure;

  @override
  List<Object?> get props => [status, races, season, failure];
}
