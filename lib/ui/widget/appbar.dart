import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

const kWindowButtonWidth = 138.0;

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(final BuildContext context) => const SizedBox(
        width: kWindowButtonWidth,
        height: 50,
        child: RepaintBoundary(child: WindowCaption()),
      );
}
