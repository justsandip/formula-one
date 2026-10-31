import 'package:storage/storage.dart';
import 'package:test/test.dart';

void main() {
  group('StorageException', () {
    test('keeps the error and mentions it in toString', () {
      final error = StateError('boom');
      final exception = StorageException(error);

      expect(exception.error, error);
      expect(exception.toString(), 'StorageException: $error');
    });
  });
}
