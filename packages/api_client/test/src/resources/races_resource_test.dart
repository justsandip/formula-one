import 'package:api_client/api_client.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFormulaOneApiClient extends Mock implements FormulaOneApiClient {}

Map<String, dynamic> _raceJson() => <String, dynamic>{
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
      'time': '04:00:00Z',
    };

Map<String, dynamic> _body(List<Map<String, dynamic>> races) =>
    <String, dynamic>{
      'MRData': <String, dynamic>{
        'RaceTable': <String, dynamic>{'Races': races},
      },
    };

void main() {
  group('RacesResource', () {
    late FormulaOneApiClient apiClient;
    late RacesResource resource;

    setUp(() {
      apiClient = _MockFormulaOneApiClient();
      resource = RacesResource(apiClient: apiClient);
    });

    group('getRaces', () {
      test('requests the current season by default', () async {
        when(() => apiClient.get('/current.json'))
            .thenAnswer((_) async => _body([_raceJson()]));

        final races = await resource.getRaces();

        expect(races, hasLength(1));
        expect(races.first.round, '1');
        expect(races.first.name, 'Australian Grand Prix');
        expect(races.first.circuit.id, 'albert_park');
        expect(races.first.startsAt, DateTime.utc(2026, 3, 8, 4));
        verify(() => apiClient.get('/current.json')).called(1);
      });

      test('requests the given season', () async {
        when(() => apiClient.get('/2025.json'))
            .thenAnswer((_) async => _body([_raceJson()]));

        await resource.getRaces(season: 2025);

        verify(() => apiClient.get('/2025.json')).called(1);
      });

      test('returns an empty list when there are no races', () async {
        when(() => apiClient.get('/current.json'))
            .thenAnswer((_) async => _body([]));

        expect(await resource.getRaces(), isEmpty);
      });

      test('lets client failures through unchanged', () async {
        const failure = FormulaOneNetworkFailure('offline');
        when(() => apiClient.get('/current.json'))
            .thenAnswer((_) async => throw failure);

        await expectLater(
          resource.getRaces(),
          throwsA(same(failure)),
        );
      });

      test('throws FormulaOneDeserializationFailure without MRData', () async {
        when(() => apiClient.get('/current.json'))
            .thenAnswer((_) async => <String, dynamic>{});

        await expectLater(
          resource.getRaces(),
          throwsA(
            isA<FormulaOneDeserializationFailure>()
                .having((e) => e.message, 'message', contains('/current.json'))
                .having((e) => e.cause, 'cause', isNotNull),
          ),
        );
      });

      test('throws FormulaOneDeserializationFailure when Races is not a list',
          () async {
        when(() => apiClient.get('/current.json')).thenAnswer(
          (_) async => <String, dynamic>{
            'MRData': <String, dynamic>{
              'RaceTable': <String, dynamic>{'Races': 'nope'},
            },
          },
        );

        await expectLater(
          resource.getRaces(),
          throwsA(isA<FormulaOneDeserializationFailure>()),
        );
      });

      test('throws FormulaOneDeserializationFailure when a race is invalid',
          () async {
        final broken = _raceJson()..remove('raceName');
        when(() => apiClient.get('/current.json'))
            .thenAnswer((_) async => _body([broken]));

        await expectLater(
          resource.getRaces(),
          throwsA(isA<FormulaOneDeserializationFailure>()),
        );
      });
    });
  });
}
