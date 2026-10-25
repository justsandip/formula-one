import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

import '../../helpers/standings_fixtures.dart';

void main() {
  group('Constructor', () {
    test('fromJson maps constructorId to id', () {
      final constructor = Constructor.fromJson(constructorJson());

      expect(constructor.id, 'mclaren');
      expect(constructor.name, 'McLaren');
      expect(constructor.nationality, 'British');
    });

    test('supports value equality', () {
      expect(
        Constructor.fromJson(constructorJson()),
        Constructor.fromJson(constructorJson()),
      );
    });

    test('differs when a field differs', () {
      expect(
        Constructor.fromJson(constructorJson()),
        isNot(Constructor.fromJson(constructorJson(id: 'ferrari'))),
      );
    });

    test('toString lists every field', () {
      expect(
        Constructor.fromJson(constructorJson()).toString(),
        'Constructor(mclaren, McLaren, British)',
      );
    });
  });
}
