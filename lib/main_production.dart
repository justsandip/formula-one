import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:formula_one/app/app.dart';
import 'package:formula_one/bootstrap.dart';
import 'package:formula_one_repository/formula_one_repository.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:persistent_storage/persistent_storage.dart';
import 'package:response_cache/response_cache.dart';

Future<void> main() async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  WidgetsFlutterBinding.ensureInitialized();

  final storageDatabase = StorageDatabase(
    driftDatabase(
      name: 'storage',
      native: const DriftNativeOptions(
        databaseDirectory: path_provider.getApplicationSupportDirectory,
      ),
    ),
  );

  final apiClient = FormulaOneApiClient(
    cache: ResponseCache(storage: PersistentStorage(database: storageDatabase)),
  );
  final formulaOneRepository = FormulaOneRepository(apiClient: apiClient);

  await bootstrap(() => App(formulaOneRepository: formulaOneRepository));
}
