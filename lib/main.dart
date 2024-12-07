import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:window_manager/window_manager.dart';

import 'src/app_state/exe_arg.dart';
import 'src/error_handler/error_handler.dart';
import 'src/ui/app.dart';
import 'src/ui/constants.dart';

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
  await protocolHandler.register(protocol);
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      titleBarStyle: TitleBarStyle.hidden,
      minimumSize: Size(800, 600),
    ),
  );
}
