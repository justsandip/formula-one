// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circuit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Circuit _$CircuitFromJson(Map<String, dynamic> json) => Circuit(
  id: json['circuitId'] as String,
  name: json['circuitName'] as String,
  location: Circuit._readLocation(json, 'locality') as String,
  country: Circuit._readLocation(json, 'country') as String,
  latitude: double.parse(Circuit._readLocation(json, 'lat') as String),
  longitude: double.parse(Circuit._readLocation(json, 'long') as String),
);
