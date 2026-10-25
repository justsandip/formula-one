import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'driver.g.dart';

/// {@template driver}
/// A Formula One Driver
/// {@endtemplate}
@JsonSerializable(createToJson: false)
class Driver extends Equatable {
  /// {@macro driver}
  const Driver({
    required this.id,
    required this.permanentNumber,
    required this.code,
    required this.givenName,
    required this.familyName,
    required this.nationality,
  });

  /// Converts a JSON [Map] into a [Driver] instance
  factory Driver.fromJson(Map<String, dynamic> json) => _$DriverFromJson(json);

  /// The identifier of the [Driver]
  @JsonKey(name: 'driverId')
  final String id;

  /// The permanent number for the [Driver]
  final String permanentNumber;

  /// Three letter code name
  final String code;

  /// Given name
  final String givenName;

  /// Family name
  final String familyName;

  /// Nationality of the [Driver]
  final String nationality;

  @override
  List<Object?> get props => [
    id,
    permanentNumber,
    code,
    givenName,
    familyName,
    nationality,
  ];

  @override
  String toString() =>
      '''Driver($id, $permanentNumber, $code, $givenName, $familyName, $nationality)''';
}
