// ignore_for_file: document_ignores, avoid_redundant_argument_values

import 'package:response_cache/response_cache.dart';
import 'package:test/test.dart';

void main() {
  group('cacheKey', () {
    test('is the path when there are no query parameters', () {
      expect(cacheKey('/current.json'), '/current.json');
      expect(cacheKey('/current.json', null), '/current.json');
      expect(cacheKey('/current.json', const {}), '/current.json');
    });

    test('appends the query parameters', () {
      expect(
        cacheKey('/2025/17/results.json', {'limit': 100}),
        '/2025/17/results.json?limit=100',
      );
    });

    test('sorts the parameters so their order does not matter', () {
      expect(
        cacheKey('/x.json', {'offset': 0, 'limit': 100}),
        cacheKey('/x.json', {'limit': 100, 'offset': 0}),
      );
      expect(
        cacheKey('/x.json', {'offset': 0, 'limit': 100}),
        '/x.json?limit=100&offset=0',
      );
    });

    test('gives different keys for different values', () {
      expect(
        cacheKey('/x.json', {'limit': 1}),
        isNot(cacheKey('/x.json', {'limit': 2})),
      );
    });
  });
}
