import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

import '../../helpers/results_fixtures.dart';

void main() {
  group('RaceResults', () {
    RaceResults build({String status = 'Finished'}) => RaceResults(
      race: Race.fromJson(raceJson()),
      results: [RaceResult.fromJson(raceResultJson(status: status))],
    );

    test('exposes the race and its results', () {
      final raceResults = build();

      expect(raceResults.race.name, 'Singapore Grand Prix');
      expect(raceResults.results, hasLength(1));
    });

    test('supports value equality', () {
      expect(build(), build());
    });

    test('differs when the results differ', () {
      expect(build(), isNot(build(status: 'Retired')));
    });

    test('toString includes the race and the results', () {
      final raceResults = build();

      expect(raceResults.toString(), startsWith('RaceResults('));
      expect(raceResults.toString(), contains(raceResults.race.toString()));
      expect(raceResults.toString(), contains(raceResults.results.toString()));
    });
  });
}
