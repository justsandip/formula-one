// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_standing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DriverStanding _$DriverStandingFromJson(Map<String, dynamic> json) =>
    DriverStanding(
      position: int.parse(json['position'] as String),
      points: double.parse(json['points'] as String),
      wins: int.parse(json['wins'] as String),
      driver: Driver.fromJson(json['Driver'] as Map<String, dynamic>),
      constructors: (json['Constructors'] as List<dynamic>)
          .map((e) => Constructor.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
