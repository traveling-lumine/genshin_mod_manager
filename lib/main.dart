import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/error_handler.dart';
import 'package:genshin_mod_manager/ui/router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:window_manager/window_manager.dart';

const _kMinWindowSize = Size(600, 600);

void main(final List<String> args) async {
  Logger().d('Starting app with args: $args');
  await _initialize();
  if (!kDebugMode) {
    registerErrorHandlers();
  }
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
