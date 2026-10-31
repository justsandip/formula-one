import 'package:api_client/api_client.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:response_cache/response_cache.dart';
import 'package:test/test.dart';

class _MockDio extends Mock implements Dio {}

class _MockResponseCache extends Mock implements ResponseCache {}

void main() {
  group('FormulaOneApiClient', () {
    late Dio dio;
    late FormulaOneApiClient client;

    final requestOptions = RequestOptions(path: '/x');

    void stubGet(Future<Response<Map<String, dynamic>>> Function() answer) {
      when(
        () => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer((_) => answer());
    }

    setUp(() {
      dio = _MockDio();
      client = FormulaOneApiClient(dio: dio);
    });

    group('constructor', () {
      test('builds its own Dio when none is given', () {
        expect(FormulaOneApiClient(), isNotNull);
        expect(
          FormulaOneApiClient.defaultBaseUrl,
          'https://api.jolpi.ca/ergast/f1',
        );
      });

      test('accepts a custom baseUrl', () {
        expect(FormulaOneApiClient(baseUrl: 'https://example.com'), isNotNull);
      });
    });

    group('racesResource', () {
      test('is created lazily and reused', () {
        expect(client.racesResource, isA<RacesResource>());
        expect(identical(client.racesResource, client.racesResource), isTrue);
      });
    });

    group('get', () {
      test('returns the decoded body', () async {
        stubGet(
          () async => Response(
            requestOptions: requestOptions,
            statusCode: 200,
            data: <String, dynamic>{'ok': true},
          ),
        );

        expect(await client.get('/x'), {'ok': true});
      });

      test('forwards query parameters', () async {
        stubGet(
          () async => Response(
            requestOptions: requestOptions,
            data: <String, dynamic>{},
          ),
        );

        await client.get('/x', queryParameters: {'limit': 5});

        verify(
          () => dio.get<Map<String, dynamic>>(
            '/x',
            queryParameters: {'limit': 5},
          ),
        ).called(1);
      });

      test(
        'throws FormulaOneMalformedResponseFailure on an empty body',
        () async {
          stubGet(() async => Response(requestOptions: requestOptions));

          await expectLater(
            client.get('/x'),
            throwsA(isA<FormulaOneMalformedResponseFailure>()),
          );
        },
      );

      test(
        'throws FormulaOneHttpFailure with the status code on badResponse',
        () async {
          final error = DioException(
            requestOptions: requestOptions,
            type: DioExceptionType.badResponse,
            message: 'Not found',
            response: Response(requestOptions: requestOptions, statusCode: 404),
          );
          stubGet(() async => throw error);

          await expectLater(
            client.get('/x'),
            throwsA(
              isA<FormulaOneHttpFailure>()
                  .having((e) => e.statusCode, 'statusCode', 404)
                  .having((e) => e.message, 'message', 'Not found')
                  .having((e) => e.cause, 'cause', error),
            ),
          );
        },
      );

      test('throws FormulaOneNetworkFailure on a timeout', () async {
        final error = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.connectionTimeout,
          message: 'timed out',
        );
        stubGet(() async => throw error);

        await expectLater(
          client.get('/x'),
          throwsA(
            isA<FormulaOneNetworkFailure>()
                .having((e) => e.message, 'message', 'timed out')
                .having((e) => e.cause, 'cause', error),
          ),
        );
      });

      test(
        'throws FormulaOneNetworkFailure on any other DioException type',
        () async {
          stubGet(
            () async => throw DioException(requestOptions: requestOptions),
          );

          await expectLater(
            client.get('/x'),
            throwsA(isA<FormulaOneNetworkFailure>()),
          );
        },
      );

      test('throws FormulaOneUnknownFailure for a non-Dio error', () async {
        final error = StateError('boom');
        stubGet(() async => throw error);

        await expectLater(
          client.get('/x'),
          throwsA(
            isA<FormulaOneUnknownFailure>()
                .having((e) => e.cause, 'cause', error)
                .having((e) => e.message, 'message', contains('/x')),
          ),
        );
      });
    });

    group('with a response cache', () {
      const baseUrl = 'https://example.com/f1';

      late ResponseCache cache;
      late FormulaOneApiClient cachedClient;

      setUpAll(() {
        registerFallbackValue(() async => <String, dynamic>{});
      });

      setUp(() {
        cache = _MockResponseCache();
        when(() => dio.options).thenReturn(BaseOptions(baseUrl: baseUrl));
        cachedClient = FormulaOneApiClient(dio: dio, cache: cache);
      });

      Response<Map<String, dynamic>> ok(Map<String, dynamic> data) =>
          Response(requestOptions: requestOptions, statusCode: 200, data: data);

      /// Simulates a cache miss: the cache calls the network callback it was
      /// given and returns its result.
      void stubMiss() {
        when(
          () => cache.fetch(
            key: any(named: 'key'),
            network: any(named: 'network'),
          ),
        ).thenAnswer((invocation) {
          final network =
              invocation.namedArguments[#network]
                  as Future<Map<String, dynamic>> Function();
          return network();
        });
      }

      void verifyNoNetworkCalls() => verifyNever(
        () => dio.get<Map<String, dynamic>>(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      );

      test(
        'returns what the cache returns without calling the network',
        () async {
          when(
            () => cache.fetch(
              key: '$baseUrl/x.json',
              network: any(named: 'network'),
            ),
          ).thenAnswer((_) async => <String, dynamic>{'n': 1});

          final body = await cachedClient.get('/x.json');

          expect(body, {'n': 1});
          verifyNoNetworkCalls();
        },
      );

      test(
        'asks the cache for a key built from the path and sorted query',
        () async {
          when(
            () => cache.fetch(
              key: '$baseUrl/x.json?a=1&b=2',
              network: any(named: 'network'),
            ),
          ).thenAnswer((_) async => <String, dynamic>{'n': 1});

          await cachedClient.get('/x.json', queryParameters: {'b': 2, 'a': 1});

          verify(
            () => cache.fetch(
              key: '$baseUrl/x.json?a=1&b=2',
              network: any(named: 'network'),
            ),
          ).called(1);
        },
      );

      test(
        'on a miss the callback performs the request with its parameters',
        () async {
          stubMiss();
          stubGet(() async => ok(<String, dynamic>{'n': 1}));

          final body = await cachedClient.get(
            '$baseUrl/x.json',
            queryParameters: {'limit': 100},
          );

          expect(body, {'n': 1});
          verify(
            () => dio.get<Map<String, dynamic>>(
              '$baseUrl/x.json',
              queryParameters: {'limit': 100},
            ),
          ).called(1);
        },
      );

      test(
        'a network failure inside the callback reaches the caller',
        () async {
          stubMiss();
          stubGet(
            () async => throw DioException(
              requestOptions: requestOptions,
              type: DioExceptionType.connectionTimeout,
            ),
          );

          await expectLater(
            cachedClient.get('$baseUrl/x.json'),
            throwsA(isA<FormulaOneNetworkFailure>()),
          );
        },
      );

      test('a failure from the cache itself is not swallowed', () async {
        final failure = StateError('cache broke');
        when(
          () => cache.fetch(
            key: any(named: 'key'),
            network: any(named: 'network'),
          ),
        ).thenAnswer((_) async => throw failure);

        await expectLater(
          cachedClient.get('$baseUrl/x.json'),
          throwsA(same(failure)),
        );
      });
    });
  });
}
