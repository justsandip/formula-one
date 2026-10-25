import 'package:api_client/api_client.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'driver_standing.g.dart';

/// {@template driver_standing}
/// The current standing for the Drivers' Championship
/// {@endtemplate}
@JsonSerializable(createToJson: false)
class DriverStanding extends Equatable {
  /// {@macro driver_standing}
  const DriverStanding({
    required this.position,
    required this.points,
    required this.wins,
    required this.driver,
    required this.constructors,
  });

  /// Converts a JSON [Map] into a [DriverStanding] instance
  factory DriverStanding.fromJson(Map<String, dynamic> json) =>
      _$DriverStandingFromJson(json);

  /// Current position in the Drivers' Championship
  @JsonKey(fromJson: int.parse)
  final int position;

  /// Current total points
  @JsonKey(fromJson: double.parse)
  final double points;

  /// Number of race wins in the season
  @JsonKey(fromJson: int.parse)
  final int wins;

  /// [Driver] details
  @JsonKey(name: 'Driver')
  final Driver driver;

  /// Teams driven for this season (more than one after a mid-season move)
  @JsonKey(name: 'Constructors')
  final List<Constructor> constructors;

  @override
  List<Object?> get props => [position, points, wins, driver, constructors];

  @override
  String toString() =>
      '''DriverStanding($position, $points, $wins, $driver, $constructors)''';
}
