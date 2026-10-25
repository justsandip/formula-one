import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

import '../../helpers/standings_fixtures.dart';

void main() {
  group('Driver', () {
    test('fromJson maps the Ergast keys and ignores the rest', () {
      final driver = Driver.fromJson(driverJson());

      expect(driver.id, 'norris');
      expect(driver.permanentNumber, '4');
      expect(driver.code, 'NOR');
      expect(driver.givenName, 'Lando');
      expect(driver.familyName, 'Norris');
      expect(driver.nationality, 'British');
    });

    test('supports value equality', () {
      expect(Driver.fromJson(driverJson()), Driver.fromJson(driverJson()));
    });

    test('differs when a field differs', () {
      expect(
        Driver.fromJson(driverJson()),
        isNot(Driver.fromJson(driverJson(code: 'XYZ'))),
      );
    });

    test('toString lists every field', () {
      expect(
        Driver.fromJson(driverJson()).toString(),
        'Driver(norris, 4, NOR, Lando, Norris, British)',
      );
    });
  });
}
