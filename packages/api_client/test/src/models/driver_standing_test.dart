import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

import '../../helpers/standings_fixtures.dart';

void main() {
  group('DriverStanding', () {
    test('fromJson parses the numeric strings and nested objects', () {
      final standing = DriverStanding.fromJson(driverStandingJson());

      expect(standing.position, 1);
      expect(standing.points, 408.0);
      expect(standing.wins, 7);
      expect(standing.driver.code, 'NOR');
      expect(standing.constructors, hasLength(1));
      expect(standing.constructors.single.name, 'McLaren');
    });

    test('fromJson parses fractional points', () {
      final standing = DriverStanding.fromJson(
        driverStandingJson(points: '12.5'),
      );

      expect(standing.points, 12.5);
    });

    test('fromJson keeps every team after a mid-season move', () {
      final standing = DriverStanding.fromJson(
        driverStandingJson(
          constructors: [
            constructorJson(id: 'alpine', name: 'Alpine'),
            constructorJson(),
          ],
        ),
      );

      expect(standing.constructors.map((c) => c.id), ['alpine', 'mclaren']);
    });

    test('fromJson throws a FormatException for a non-numeric position', () {
      expect(
        () => DriverStanding.fromJson(driverStandingJson(position: 'x')),
        throwsFormatException,
      );
    });

    test('supports value equality', () {
      expect(
        DriverStanding.fromJson(driverStandingJson()),
        DriverStanding.fromJson(driverStandingJson()),
      );
    });

    test('differs when points differ', () {
      expect(
        DriverStanding.fromJson(driverStandingJson()),
        isNot(DriverStanding.fromJson(driverStandingJson(points: '1'))),
      );
    });

    test('toString lists every field', () {
      expect(
        DriverStanding.fromJson(driverStandingJson()).toString(),
        'DriverStanding(1, 408.0, 7, '
        'Driver(norris, 4, NOR, Lando, Norris, British), '
        '[Constructor(mclaren, McLaren, British)])',
      );
    });
  });
}
