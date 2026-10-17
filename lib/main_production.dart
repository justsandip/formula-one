import 'package:formula_one/app/app.dart';
import 'package:formula_one/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
