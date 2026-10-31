import 'dart:convert';

import 'package:response_cache/src/cached_response.dart';
import 'package:test/test.dart';

void main() {
  group('CachedResponse', () {
    final response = CachedResponse(
      body: const {'a': 1},
      fetchedAt: DateTime.utc(2026, 10, 30, 12, 0, 0, 123),
      formatVersion: 1,
    );

    test('encodes to a JSON string with every field', () {
      expect(jsonDecode(response.encode()), {
        'formatVersion': 1,
        'fetchedAt': DateTime.utc(2026, 10, 30, 12, 0, 0, 123)
            .millisecondsSinceEpoch,
        'body': {'a': 1},
      });
    });

    test('round-trips through encode and tryDecode', () {
      final decoded = CachedResponse.tryDecode(response.encode());

      expect(decoded, response);
      expect(decoded?.fetchedAt.isUtc, isTrue);
    });

    test('encodes a local fetch time as UTC', () {
      final local = CachedResponse(
        body: const {},
        fetchedAt: DateTime(2026, 10, 30, 12),
        formatVersion: 1,
      );

      expect(
        CachedResponse.tryDecode(local.encode())?.fetchedAt,
        DateTime(2026, 10, 30, 12).toUtc(),
      );
    });

    group('tryDecode returns null for', () {
      for (final source in <String, String>{
        'text that is not JSON': 'not json',
        'JSON that is not an object': '[1,2]',
        'an empty object': '{}',
        'a non-integer format version':
            '{"formatVersion":"1","fetchedAt":0,"body":{}}',
        'a non-integer fetch time':
            '{"formatVersion":1,"fetchedAt":"0","body":{}}',
        'a body that is not an object':
            '{"formatVersion":1,"fetchedAt":0,"body":[]}',
        'a missing body': '{"formatVersion":1,"fetchedAt":0}',
      }.entries) {
        test(source.key, () {
          expect(CachedResponse.tryDecode(source.value), isNull);
        });
      }
    });

    test('supports value equality', () {
      expect(
        response,
        CachedResponse(
          body: const {'a': 1},
          fetchedAt: DateTime.utc(2026, 10, 30, 12, 0, 0, 123),
          formatVersion: 1,
        ),
      );
      expect(
        response,
        isNot(
          CachedResponse(
            body: const {'a': 2},
            fetchedAt: DateTime.utc(2026, 10, 30, 12, 0, 0, 123),
            formatVersion: 1,
          ),
        ),
      );
    });
  });
}
