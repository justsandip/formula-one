// ignore_for_file: document_ignores, avoid_redundant_argument_values

import 'package:api_client/api_client.dart';
import 'package:formula_one_repository/formula_one_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFormulaOneApiClient extends Mock implements FormulaOneApiClient {}

class _MockRacesResource extends Mock implements RacesResource {}

void main() {
  group('FormulaOneRepository', () {
    late FormulaOneApiClient apiClient;
    late RacesResource racesResource;
    late FormulaOneRepository repository;

    final race = Race(
      round: '1',
      name: 'Australian Grand Prix',
      circuit: const Circuit(
        id: 'albert_park',
        name: 'Albert Park Grand Prix Circuit',
        location: 'Melbourne',
        country: 'Australia',
        latitude: -37.8497,
        longitude: 144.968,
      ),
      startsAt: DateTime.utc(2026, 3, 8, 4),
    );

    setUp(() {
      apiClient = _MockFormulaOneApiClient();
      racesResource = _MockRacesResource();
      when(() => apiClient.racesResource).thenReturn(racesResource);
      repository = FormulaOneRepository(apiClient: apiClient);
    });

    group('getRaces', () {
      test('returns the current season races by default', () async {
        when(
          () => racesResource.getRaces(season: null),
        ).thenAnswer((_) async => [race]);

        expect(await repository.getRaces(), [race]);
        verify(() => racesResource.getRaces(season: null)).called(1);
      });

      test('passes the requested season through', () async {
        when(
          () => racesResource.getRaces(season: 2025),
        ).thenAnswer((_) async => [race]);

        expect(await repository.getRaces(season: 2025), [race]);
        verify(() => racesResource.getRaces(season: 2025)).called(1);
      });

      test('lets api failures through unchanged', () async {
        const failure = FormulaOneNetworkFailure('offline');
        when(
          () => racesResource.getRaces(season: null),
        ).thenAnswer((_) async => throw failure);

        await expectLater(repository.getRaces(), throwsA(same(failure)));
      });
    });
  });
}
