import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'constructor.g.dart';

/// {@template constructor}
/// A Formula One Team (Constructor).
/// {@endtemplate}
@JsonSerializable(createToJson: false)
class Constructor extends Equatable {
  /// {@macro constructor}
  const Constructor({
    required this.id,
    required this.name,
    required this.nationality,
  });

  /// Converts a JSON [Map] into a [Constructor] instance
  factory Constructor.fromJson(Map<String, dynamic> json) =>
      _$ConstructorFromJson(json);

  /// The identifier of the [Constructor]
  @JsonKey(name: 'constructorId')
  final String id;

  /// Name of the [Constructor]
  final String name;

  /// Nationality of Constructor
  final String nationality;

  @override
  List<Object?> get props => [id, name, nationality];

  @override
  String toString() => '''Constructor($id, $name, $nationality)''';
}
