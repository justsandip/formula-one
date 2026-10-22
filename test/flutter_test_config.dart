import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Never hit the network from tests.
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
