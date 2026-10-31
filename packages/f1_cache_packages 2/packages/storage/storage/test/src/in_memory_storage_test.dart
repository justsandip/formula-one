import 'package:storage/storage.dart';
import 'package:storage/testing.dart';
import 'package:test/test.dart';

void main() {
  group('InMemoryStorage', () {
    runStorageContractTests(InMemoryStorage.new);

    test('does not share values between instances', () async {
      final first = InMemoryStorage();
      final second = InMemoryStorage();
      await first.write(key: 'k', value: 'v');

      expect(await second.read(key: 'k'), isNull);
    });
  });
}
