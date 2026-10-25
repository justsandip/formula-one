import 'package:api_client/api_client.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'constructor_standing.g.dart';

/// {@template constructor_standing}
/// The current standing for the Constructors' Championship
/// {@endtemplate}
@JsonSerializable(createToJson: false)
class ConstructorStanding extends Equatable {
  /// {@macro constructor_standing}
  const ConstructorStanding({
    required this.position,
    required this.points,
    required this.wins,
    required this.constructor,
  });

  /// Converts a JSON [Map] into a [ConstructorStanding] instance
  factory ConstructorStanding.fromJson(Map<String, dynamic> json) =>
      _$ConstructorStandingFromJson(json);

  /// Current position in the Constructors' Championship
  @JsonKey(fromJson: int.parse)
  final int position;

  /// Current total points
  @JsonKey(fromJson: double.parse)
  final double points;

  /// Number of race wins in the season
  @JsonKey(fromJson: int.parse)
  final int wins;

  /// The Formula One Team (Constructor)
  @JsonKey(name: 'Constructor')
  final Constructor constructor;

  @override
  List<Object?> get props => [position, points, wins, constructor];

  @override
  String toString() =>
      '''ConstructorStanding($position, $points, $wins, $constructor)''';
}
