import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/service/app_state_service.dart';
import 'package:genshin_mod_manager/window/loading_screen.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

const _minWindowSize = Size(600, 600);

void main() async {
  await initialize();
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
