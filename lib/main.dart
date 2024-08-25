import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'ui/di/exe_arg.dart';
import 'error_handler.dart';
import 'ui/router.dart';

const _kMinWindowSize = Size(800, 600);

void main(final List<String> args) async {
  await _initialize();
  if (!kDebugMode) {
    registerErrorHandlers();
  }
  ArgProvider.initial = args;
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      titleBarStyle: TitleBarStyle.hidden,
      minimumSize: _kMinWindowSize,
    ),
  );
}
