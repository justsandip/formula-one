import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

import '../../helpers/standings_fixtures.dart';

void main() {
  group('ConstructorStanding', () {
    test('fromJson parses the numeric strings and the nested team', () {
      final standing = ConstructorStanding.fromJson(constructorStandingJson());

      expect(standing.position, 1);
      expect(standing.points, 800.0);
      expect(standing.wins, 14);
      expect(standing.constructor.id, 'mclaren');
    });

    test('fromJson throws a FormatException for non-numeric points', () {
      expect(
        () => ConstructorStanding.fromJson(
          constructorStandingJson(points: 'lots'),
        ),
        throwsFormatException,
      );
    });

    test('supports value equality', () {
      expect(
        ConstructorStanding.fromJson(constructorStandingJson()),
        ConstructorStanding.fromJson(constructorStandingJson()),
      );
    });

    test('differs when wins differ', () {
      expect(
        ConstructorStanding.fromJson(constructorStandingJson()),
        isNot(ConstructorStanding.fromJson(constructorStandingJson(wins: '1'))),
      );
    });

    test('toString lists every field', () {
      expect(
        ConstructorStanding.fromJson(constructorStandingJson()).toString(),
        'ConstructorStanding(1, 800.0, 14, '
        'Constructor(mclaren, McLaren, British))',
      );
    });
  });
}
