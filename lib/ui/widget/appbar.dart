import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

/// The width of window control button row.
const kWindowButtonWidth = 138.0;

/// A widget that provides window buttons.
class WindowButtons extends StatelessWidget {
  /// Creates a [WindowButtons].
  const WindowButtons({super.key});

  @override
  Widget build(final BuildContext context) => const SizedBox(
        width: kWindowButtonWidth,
        height: 50,
        child: RepaintBoundary(child: WindowCaption()),
      );
}

/// A widget that provides a navigation appbar.
NavigationAppBar getAppbar(final String text) => NavigationAppBar(
      actions: const WindowButtons(),
      automaticallyImplyLeading: false,
      title: DragToMoveArea(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(text),
        ),
      ),
    );
