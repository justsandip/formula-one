import 'standings_fixtures.dart';

/// Sample JSON shaped like a Jolpica (Ergast) race results response.
/// Values are made up; only the structure matters.
Map<String, dynamic> raceResultJson({
  String position = '1',
  String positionText = '1',
  String points = '25',
  String grid = '1',
  String laps = '57',
  String status = 'Finished',
  Map<String, dynamic>? time = const {
    'millis': '6126304',
    'time': '1:42:06.304',
  },
}) => <String, dynamic>{
  'number': '4',
  'position': position,
  'positionText': positionText,
  'points': points,
  'Driver': driverJson(),
  'Constructor': constructorJson(),
  'grid': grid,
  'laps': laps,
  'status': status,
  'Time': ?time,
};

/// The `Races` entry for a race, without its results.
Map<String, dynamic> raceJson() => <String, dynamic>{
  'season': '2026',
  'round': '17',
  'url': 'https://en.wikipedia.org/wiki/2026_Singapore_Grand_Prix',
  'raceName': 'Singapore Grand Prix',
  'Circuit': <String, dynamic>{
    'circuitId': 'marina_bay',
    'url': 'https://en.wikipedia.org/wiki/Marina_Bay_Street_Circuit',
    'circuitName': 'Marina Bay Street Circuit',
    'Location': <String, dynamic>{
      'lat': '1.2914',
      'long': '103.864',
      'locality': 'Marina Bay',
      'country': 'Singapore',
    },
  },
  'date': '2026-10-11',
  'time': '12:00:00Z',
};

/// A full response body. [total] defaults to the number of rows.
Map<String, dynamic> raceResultsBody(
  List<Map<String, dynamic>> results, {
  String? total,
}) => <String, dynamic>{
  'MRData': <String, dynamic>{
    'limit': '100',
    'offset': '0',
    'total': total ?? '${results.length}',
    'RaceTable': <String, dynamic>{
      'Races': <dynamic>[
        <String, dynamic>{...raceJson(), 'Results': results},
      ],
    },
  },
};

/// A response for a race that has not been run: no `Races` at all.
Map<String, dynamic> emptyRaceResultsBody() => <String, dynamic>{
  'MRData': <String, dynamic>{
    'limit': '100',
    'offset': '0',
    'total': '0',
    'RaceTable': <String, dynamic>{'Races': <dynamic>[]},
  },
};
