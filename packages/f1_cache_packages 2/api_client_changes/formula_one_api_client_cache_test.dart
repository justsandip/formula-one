// Add this group inside the existing `group('FormulaOneApiClient', ...)` of
// formula_one_api_client_test.dart. It reuses the `dio`, `requestOptions` and
// `stubGet` helpers from that file.
//
// Extra imports for that file:
//   import 'package:response_cache/response_cache.dart';
//   import 'package:storage/storage.dart';

group('with a response cache', () {
  late FormulaOneApiClient cachedClient;

  setUp(() {
    cachedClient = FormulaOneApiClient(
      dio: dio,
      cache: ResponseCache(storage: InMemoryStorage()),
    );
  });

  Response<Map<String, dynamic>> ok(Map<String, dynamic> data) =>
      Response(requestOptions: requestOptions, statusCode: 200, data: data);

  test('serves a repeated request from the cache', () async {
    stubGet(() async => ok(<String, dynamic>{'n': 1}));

    final first = await cachedClient.get('/x.json');
    final second = await cachedClient.get('/x.json');

    expect(first, {'n': 1});
    expect(second, {'n': 1});
    verify(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).called(1);
  });

  test('treats query parameters given in another order as one request',
      () async {
    stubGet(() async => ok(<String, dynamic>{'n': 1}));

    await cachedClient.get('/x.json', queryParameters: {'a': 1, 'b': 2});
    await cachedClient.get('/x.json', queryParameters: {'b': 2, 'a': 1});

    verify(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).called(1);
  });

  test('keeps different paths apart', () async {
    stubGet(() async => ok(<String, dynamic>{'n': 1}));

    await cachedClient.get('/a.json');
    await cachedClient.get('/b.json');

    verify(
      () => dio.get<Map<String, dynamic>>(
        any(),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).called(2);
  });

  test('does not cache a failure', () async {
    stubGet(() async => throw StateError('boom'));
    await expectLater(
      cachedClient.get('/x.json'),
      throwsA(isA<FormulaOneUnknownFailure>()),
    );

    stubGet(() async => ok(<String, dynamic>{'n': 1}));
    final body = await cachedClient.get('/x.json');

    expect(body, {'n': 1});
  });
});
