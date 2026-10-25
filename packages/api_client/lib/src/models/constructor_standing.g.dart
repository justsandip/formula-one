// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'constructor_standing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConstructorStanding _$ConstructorStandingFromJson(Map<String, dynamic> json) =>
    ConstructorStanding(
      position: int.parse(json['position'] as String),
      points: double.parse(json['points'] as String),
      wins: int.parse(json['wins'] as String),
      constructor: Constructor.fromJson(
        json['Constructor'] as Map<String, dynamic>,
      ),
    );
