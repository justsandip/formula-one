part of 'schedule_bloc.dart';

@immutable
sealed class ScheduleEvent extends Equatable {
  const new();
}

/// {@template schedule_requested}
/// Loads the races of [season], or of the current season when null.
/// Also retries after a failure.
/// {@endtemplate}
final class ScheduleRequested extends ScheduleEvent {
  /// {@macro schedule_requested}
  const new({this.season});

  /// Season year, or null for the current season.
  final int? season;

  @override
  List<Object?> get props => [season];
}
