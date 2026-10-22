import 'package:api_client/api_client.dart';

/// Builds a [Race]. Defaults: name `Race <round> Grand Prix`, circuit
/// `Circuit <round>` in `City <round>`.
Race buildRace({
  required DateTime startsAt,
  int round = 1,
  String? name,
}) {
  return Race(
    round: '$round',
    name: name ?? 'Race $round Grand Prix',
    circuit: Circuit(
      id: 'circuit_$round',
      name: 'Circuit $round',
      location: 'City $round',
      country: 'Country',
      latitude: 0,
      longitude: 0,
    ),
    startsAt: startsAt,
  );
}
