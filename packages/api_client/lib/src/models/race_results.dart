import 'package:api_client/api_client.dart';
import 'package:equatable/equatable.dart';

/// {@template race_results}
/// A [Race] together with its classification.
/// {@endtemplate}
class RaceResults extends Equatable {
  /// {@macro race_results}
  const RaceResults({required this.race, required this.results});

  /// The race the results belong to
  final Race race;

  /// Classification, in finishing order
  final List<RaceResult> results;

  @override
  List<Object> get props => [race, results];

  @override
  String toString() => '''RaceResults($race, $results)''';
}
