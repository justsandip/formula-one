import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

Map<String, dynamic> _raceJson({
  String? time = '04:00:00Z',
}) => <String, dynamic>{
  'season': '2026',
  'round': '1',
  'raceName': 'Australian Grand Prix',
  'Circuit': <String, dynamic>{
    'circuitId': 'albert_park',
    'circuitName': 'Albert Park Grand Prix Circuit',
    'Location': <String, dynamic>{
      'lat': '-37.8497',
      'long': '144.968',
      'locality': 'Melbourne',
      'country': 'Australia',
    },
  },
  'date': '2026-03-08',
  'time': ?time,
  'FirstPractice': <String, dynamic>{'date': '2026-03-06', 'time': '01:30:00Z'},
};

void main() {
  group('Race', () {
    test('fromJson maps every field and ignores unknown keys', () {
      final race = Race.fromJson(_raceJson());

      expect(race.round, '1');
      expect(race.name, 'Australian Grand Prix');
      expect(race.circuit.id, 'albert_park');
      expect(race.startsAt, DateTime.utc(2026, 3, 8, 4));
      expect(race.startsAt.isUtc, isTrue);
    });

    test('startsAt falls back to midnight UTC when time is missing', () {
      final race = Race.fromJson(_raceJson(time: null));

      expect(race.startsAt, DateTime.utc(2026, 3, 8));
    });

    test('supports value equality', () {
      expect(Race.fromJson(_raceJson()), Race.fromJson(_raceJson()));
    });

    test('differs when the round differs', () {
      final other = _raceJson()..['round'] = '2';

      expect(Race.fromJson(_raceJson()), isNot(Race.fromJson(other)));
    });

    test('toString lists every field', () {
      expect(
        Race.fromJson(_raceJson()).toString(),
        'Race(1, Australian Grand Prix, Circuit(albert_park, '
        'Albert Park Grand Prix Circuit, Melbourne, Australia, -37.8497, '
        '144.968), 2026-03-08 04:00:00.000Z)',
      );
    });
  });
}
