// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'race.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Race _$RaceFromJson(Map<String, dynamic> json) => Race(
      round: json['round'] as String,
      name: json['raceName'] as String,
      circuit: Circuit.fromJson(json['Circuit'] as Map<String, dynamic>),
      startsAt: DateTime.parse(Race._readStartsAt(json, 'startsAt') as String),
    );
