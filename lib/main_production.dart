import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:flutter/widgets.dart';
import 'package:formula_one/app/app.dart';
import 'package:formula_one/bootstrap.dart';
import 'package:formula_one_repository/formula_one_repository.dart';

Future<void> main() async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };
  
  final apiClient = FormulaOneApiClient();
  final formulaOneRepository = FormulaOneRepository(apiClient: apiClient);

  await bootstrap(() => App(formulaOneRepository: formulaOneRepository));
}
