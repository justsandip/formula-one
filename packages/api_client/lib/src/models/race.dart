import 'package:api_client/api_client.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'race.g.dart';

/// {@template race}
/// A scheduled Grand Prix Race
/// {@endtemplate}
@JsonSerializable(createToJson: false)
class Race extends Equatable {
  /// {@macro race}
  const Race({
    required this.round,
    required this.name,
    required this.circuit,
    required this.startsAt,
  });

  /// Converts a JSON [Map] into a [Race] instance
  factory Race.fromJson(Map<String, dynamic> json) => _$RaceFromJson(json);

  /// Race number within the season.
  final String round;

  /// Grand Prix name.
  @JsonKey(name: 'raceName')
  final String name;

  /// Where the race is held.
  @JsonKey(name: 'Circuit')
  final Circuit circuit;

  /// Race start in UTC.
  @JsonKey(readValue: _readStartsAt)
  final DateTime startsAt;

  @override
  List<Object?> get props => [round, name, circuit, startsAt];

  /// Combines the `date` and `time` keys into one ISO-8601 UTC string.
  /// If the race has no `time`, falls back to midnight UTC.
  static Object? _readStartsAt(Map<dynamic, dynamic> json, String key) {
    final time = json['time'] as String? ?? '00:00:00Z';
    return '${json['date']}T$time';
  }

  @override
  String toString() => '''Race($round, $name, $circuit, $startsAt)''';
}
