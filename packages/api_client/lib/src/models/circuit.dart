import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'circuit.g.dart';

/// {@template circuit}
/// A model containing data about a Race Circuit
/// {@endtemplate}
@JsonSerializable(createToJson: false)
class Circuit extends Equatable {
  /// {@macro circuit}
  const Circuit({
    required this.id,
    required this.name,
    required this.location,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  /// Converts a JSON [Map] into a [Circuit] instance
  factory Circuit.fromJson(Map<String, dynamic> json) =>
      _$CircuitFromJson(json);

  /// The identifier of the Circuit
  @JsonKey(name: 'circuitId')
  final String id;

  /// The name of the Circuit
  @JsonKey(name: 'circuitName')
  final String name;

  /// Location (specifically city) where the Circuit is
  @JsonKey(name: 'locality', readValue: _readLocation)
  final String location;

  /// Country where the Circuit is located
  @JsonKey(readValue: _readLocation)
  final String country;

  /// Latitude of the Circuit
  @JsonKey(name: 'lat', readValue: _readLocation, fromJson: double.parse)
  final double latitude;

  /// Longitude of the Circuit
  @JsonKey(name: 'long', readValue: _readLocation, fromJson: double.parse)
  final double longitude;

  @override
  List<Object?> get props => [id, name, location, country, latitude, longitude];

  /// Reads [key] from the nested `Location` object.
  static Object? _readLocation(Map<dynamic, dynamic> json, String key) =>
      (json['Location'] as Map<dynamic, dynamic>)[key];

  @override
  String toString() =>
      '''Circuit($id, $name, $location, $country, $latitude, $longitude)''';
}
