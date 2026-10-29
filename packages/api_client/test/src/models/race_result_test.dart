import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

import '../../helpers/results_fixtures.dart';

void main() {
  group('RaceResult', () {
    test('fromJson maps a classified result', () {
      final result = RaceResult.fromJson(raceResultJson());

      expect(result.position, 1);
      expect(result.positionText, '1');
      expect(result.points, 25.0);
      expect(result.grid, 1);
      expect(result.laps, 57);
      expect(result.status, 'Finished');
      expect(result.driver.code, 'NOR');
      expect(result.constructor.id, 'mclaren');
      expect(result.time, '1:42:06.304');
    });

    test('fromJson maps a retirement without a time', () {
      final result = RaceResult.fromJson(
        raceResultJson(
          position: '20',
          positionText: 'R',
          points: '0',
          grid: '5',
          laps: '12',
          status: 'Retired',
          time: null,
        ),
      );

      expect(result.position, 20);
      expect(result.positionText, 'R');
      expect(result.points, 0.0);
      expect(result.status, 'Retired');
      expect(result.time, isNull);
    });

    test('fromJson leaves time null when Time has no time key', () {
      final result = RaceResult.fromJson(
        raceResultJson(time: {'millis': '6126304'}),
      );

      expect(result.time, isNull);
    });

    test('fromJson parses fractional points', () {
      final result = RaceResult.fromJson(raceResultJson(points: '0.5'));

      expect(result.points, 0.5);
    });

    test('fromJson throws a FormatException for a non-numeric position', () {
      expect(
        () => RaceResult.fromJson(raceResultJson(position: 'x')),
        throwsFormatException,
      );
    });

    test('supports value equality', () {
      expect(
        RaceResult.fromJson(raceResultJson()),
        RaceResult.fromJson(raceResultJson()),
      );
    });

    test('differs when a field differs', () {
      expect(
        RaceResult.fromJson(raceResultJson()),
        isNot(RaceResult.fromJson(raceResultJson(status: '+1 Lap'))),
      );
      expect(
        RaceResult.fromJson(raceResultJson()),
        isNot(RaceResult.fromJson(raceResultJson(time: null))),
      );
    });

    test('toString lists every field', () {
      expect(
        RaceResult.fromJson(raceResultJson()).toString(),
        'RaceResult(1, 1, 25.0, 1, 57, Finished, '
        'Driver(norris, 4, NOR, Lando, Norris, British), '
        'Constructor(mclaren, McLaren, British), 1:42:06.304)',
      );
    });
  });
}
