import 'package:api_client/api_client.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'race_result.g.dart';

/// Reads the nested `Time.time`, which is missing for drivers who did not
/// finish on the lead lap.
Object? _readTime(Map<dynamic, dynamic> json, String key) =>
    (json['Time'] as Map<dynamic, dynamic>?)?['time'];

/// {@template race_result}
/// One driver's result in a race.
/// {@endtemplate}
@JsonSerializable(createToJson: false)
class RaceResult extends Equatable {
  /// {@macro race_result}
  const RaceResult({
    required this.position,
    required this.positionText,
    required this.points,
    required this.grid,
    required this.laps,
    required this.status,
    required this.driver,
    required this.constructor,
    this.time,
  });

  /// Converts a JSON [Map] into a [RaceResult] instance
  factory RaceResult.fromJson(Map<String, dynamic> json) =>
      _$RaceResultFromJson(json);

  /// Finishing order
  @JsonKey(fromJson: int.parse)
  final int position;

  /// `1`, `2`, ... for classified drivers, or `R`, `D`, `W` and so on
  final String positionText;

  /// Championship points scored
  @JsonKey(fromJson: double.parse)
  final double points;

  /// Starting grid slot
  @JsonKey(fromJson: int.parse)
  final int grid;

  /// Laps completed
  @JsonKey(fromJson: int.parse)
  final int laps;

  /// For example `Finished`, `+1 Lap` or `Retired`
  final String status;

  /// The [Driver]
  @JsonKey(name: 'Driver')
  final Driver driver;

  /// The driver's team
  @JsonKey(name: 'Constructor')
  final Constructor constructor;

  /// Race time or gap text, when the API provides one
  @JsonKey(readValue: _readTime)
  final String? time;

  @override
  List<Object?> get props => [
    position,
    positionText,
    points,
    grid,
    laps,
    status,
    driver,
    constructor,
    time,
  ];

  @override
  String toString() =>
      '''RaceResult($position, $positionText, $points, $grid, $laps, $status, $driver, $constructor, $time)''';
}
