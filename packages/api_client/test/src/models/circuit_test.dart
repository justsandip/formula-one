import 'package:api_client/api_client.dart';
import 'package:test/test.dart';

Map<String, dynamic> _circuitJson() => <String, dynamic>{
  'circuitId': 'albert_park',
  'url': 'https://en.wikipedia.org/wiki/Albert_Park_Circuit',
  'circuitName': 'Albert Park Grand Prix Circuit',
  'Location': <String, dynamic>{
    'lat': '-37.8497',
    'long': '144.968',
    'locality': 'Melbourne',
    'country': 'Australia',
  },
};

void main() {
  group('Circuit', () {
    test('fromJson reads the nested Location and parses coordinates', () {
      final circuit = Circuit.fromJson(_circuitJson());

      expect(circuit.id, 'albert_park');
      expect(circuit.name, 'Albert Park Grand Prix Circuit');
      expect(circuit.location, 'Melbourne');
      expect(circuit.country, 'Australia');
      expect(circuit.latitude, -37.8497);
      expect(circuit.longitude, 144.968);
    });

    test('supports value equality', () {
      expect(
        Circuit.fromJson(_circuitJson()),
        Circuit.fromJson(_circuitJson()),
      );
    });

    test('differs when coordinates differ', () {
      final other = _circuitJson();
      (other['Location'] as Map<String, dynamic>)['lat'] = '1.0';

      expect(Circuit.fromJson(_circuitJson()), isNot(Circuit.fromJson(other)));
    });

    test('toString lists every field', () {
      expect(
        Circuit.fromJson(_circuitJson()).toString(),
        'Circuit(albert_park, Albert Park Grand Prix Circuit, Melbourne, '
        'Australia, -37.8497, 144.968)',
      );
    });
  });
}
