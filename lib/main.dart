import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/service/app_state_service.dart';
import 'package:genshin_mod_manager/window/loading_screen.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

const _minWindowSize = Size(600, 600);

void main() async {
  await initialize();

  // write to error log
  FlutterError.onError = (details) {
    // in UTC
    final now = DateTime.now().toUtc().toIso8601String();
    String stackTrace;
    try {
      stackTrace = details.stack.toString();
      // only choose lines that include genshin_mod_manager. Lines that don't include it are shrunk to ...
      final lines = [];
      int elidedLines = 0;
      for (final line in stackTrace.split('\n')) {
        if (line.contains('genshin_mod_manager')) {
          if (elidedLines > 0) {
            lines.add('... ($elidedLines lines elided)');
            elidedLines = 0;
          }
          lines.add(line);
          elidedLines = 0;
        } else {
          elidedLines++;
        }
      }
      if (elidedLines > 0) {
        lines.add('... ($elidedLines lines elided)');
      }
      stackTrace = lines.join('\n');
    } catch (e) {
      stackTrace = 'Stack trace not available';
    }
    String message;
    try {
      message = details.exception.toString();
    } catch (e) {
      try {
        message = details.toString();
      } catch (e) {
        message = 'details not available';
      }
    }
    try {
      File('error.log').writeAsStringSync(
        '[$now]\nMessage:\n$message\nStacktrace:\n$stackTrace\n\n',
        mode: FileMode.append,
      );
    } catch (e) {
      // print('Error writing to error log: $e');
    }
  };

  ErrorWidget.builder = (details) {
    return Center(
      child: SelectableText(
        () {
          try {
            return details.exception.toString();
          } catch (e) {
            try {
              return details.toString();
            } catch (e) {
              return 'An error occurred';
            }
          }
        }(),
        style: TextStyle(color: Colors.red.darker),
      ),
    );
  };
  runApp(const MyApp());
}

Future<void> initialize() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  await windowManager.waitUntilReadyToShow(const WindowOptions(
    titleBarStyle: TitleBarStyle.hidden,
    minimumSize: _minWindowSize,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Place application scope services here
    return FluentApp(
      title: 'Genshin Mod Manager',
      home: ChangeNotifierProvider(
        create: (BuildContext context) => AppStateService(),
        builder: (context, child) => const LoadingScreen(),
      ),
    );
  }
}
