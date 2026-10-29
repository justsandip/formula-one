// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'race_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RaceResult _$RaceResultFromJson(Map<String, dynamic> json) => RaceResult(
  position: int.parse(json['position'] as String),
  positionText: json['positionText'] as String,
  points: double.parse(json['points'] as String),
  grid: int.parse(json['grid'] as String),
  laps: int.parse(json['laps'] as String),
  status: json['status'] as String,
  driver: Driver.fromJson(json['Driver'] as Map<String, dynamic>),
  constructor: Constructor.fromJson(
    json['Constructor'] as Map<String, dynamic>,
  ),
  time: _readTime(json, 'time') as String?,
);
