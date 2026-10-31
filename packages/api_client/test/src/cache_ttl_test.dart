import 'package:api_client/src/cache_ttl.dart';
import 'package:test/test.dart';

void main() {
  group('cacheTtlFor', () {
    final now = DateTime.utc(2026, 10, 31);

    for (final entry in <String, Duration?>{
      '/2025.json': null,
      '/2025/driverStandings.json': null,
      '/2025/17/results.json': null,
      '/2025/last/results.json': null,
      '/2026.json': const Duration(hours: 12),
      '/2026/driverStandings.json': const Duration(hours: 1),
      '/current.json': const Duration(hours: 12),
      '/current/driverStandings.json': const Duration(hours: 1),
      '/current/constructorStandings.json': const Duration(hours: 1),
      '/current/last/results.json': const Duration(minutes: 15),
      '/current/17/results.json': const Duration(hours: 3),
      '/current/unknown.json': const Duration(hours: 1),
    }.entries) {
      test('${entry.key} -> ${entry.value ?? 'never expires'}', () {
        expect(cacheTtlFor(entry.key, now: now), entry.value);
      });
    }

    test('treats a season as over only after the year ends', () {
      expect(
        cacheTtlFor(
          '/2026/driverStandings.json',
          now: DateTime.utc(2026, 12, 31),
        ),
        const Duration(hours: 1),
      );
      expect(
        cacheTtlFor('/2026/driverStandings.json', now: DateTime.utc(2027)),
        isNull,
      );
    });
  });
}
