import 'package:api_client/api_client.dart';

/// Builds a [Race]. Defaults: name `Race <round> Grand Prix`, circuit
/// `Circuit <round>` in `City <round>`.
Race buildRace({required DateTime startsAt, int round = 1, String? name}) {
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

/// Builds a [DriverStanding]. [teams] overrides [team] to model a driver who
/// changed team mid-season.
DriverStanding buildDriverStanding({
  required int position,
  required String givenName,
  required String familyName,
  required double points,
  int wins = 0,
  String team = 'McLaren',
  List<String>? teams,
  String number = '4',
}) {
  return DriverStanding(
    position: position,
    points: points,
    wins: wins,
    driver: Driver(
      id: familyName.toLowerCase(),
      permanentNumber: number,
      code: familyName.substring(0, 3).toUpperCase(),
      givenName: givenName,
      familyName: familyName,
      nationality: 'British',
    ),
    constructors: [
      for (final name in teams ?? [team])
        Constructor(
          id: name.toLowerCase().replaceAll(' ', '_'),
          name: name,
          nationality: 'British',
        ),
    ],
  );
}

/// Builds a [ConstructorStanding].
ConstructorStanding buildConstructorStanding({
  required int position,
  required String name,
  required double points,
  int wins = 0,
  String nationality = 'British',
}) {
  return ConstructorStanding(
    position: position,
    points: points,
    wins: wins,
    constructor: Constructor(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      nationality: nationality,
    ),
  );
}

/// Made-up drivers' table: leader on 408, second on 371.
List<DriverStanding> sampleDriverStandings() => [
  buildDriverStanding(
    position: 1,
    givenName: 'Lando',
    familyName: 'Norris',
    points: 408,
    wins: 6,
  ),
  buildDriverStanding(
    position: 2,
    givenName: 'Oscar',
    familyName: 'Piastri',
    points: 371,
    wins: 5,
    number: '81',
  ),
  buildDriverStanding(
    position: 3,
    givenName: 'Max',
    familyName: 'Verstappen',
    points: 340,
    wins: 3,
    team: 'Red Bull',
    number: '1',
  ),
  buildDriverStanding(
    position: 4,
    givenName: 'Charles',
    familyName: 'Leclerc',
    points: 298,
    wins: 2,
    team: 'Ferrari',
    number: '16',
  ),
  buildDriverStanding(
    position: 5,
    givenName: 'George',
    familyName: 'Russell',
    points: 264,
    wins: 1,
    team: 'Mercedes',
    number: '63',
  ),
  buildDriverStanding(
    position: 6,
    givenName: 'Lewis',
    familyName: 'Hamilton',
    points: 231,
    team: 'Ferrari',
    number: '44',
  ),
];

/// Made-up constructors' table: leader on 779, second on 529.
List<ConstructorStanding> sampleConstructorStandings() => [
  buildConstructorStanding(position: 1, name: 'McLaren', points: 779, wins: 11),
  buildConstructorStanding(
    position: 2,
    name: 'Ferrari',
    points: 529,
    wins: 2,
    nationality: 'Italian',
  ),
  buildConstructorStanding(
    position: 3,
    name: 'Red Bull',
    points: 411,
    wins: 3,
    nationality: 'Austrian',
  ),
];
