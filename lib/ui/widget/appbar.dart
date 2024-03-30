import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/ui/widget/preset_control.dart';
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
NavigationAppBar getAppbar(
  final String text, {
  final bool presetControl = false,
}) {
  Widget title = DragToMoveArea(
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(text),
    ),
  );
  if (presetControl) {
    title = Stack(
      alignment: Alignment.centerLeft,
      children: [
        title,
        Positioned(
          right: kWindowButtonWidth,
          child: PresetControlWidget(isLocal: false),
        ),
        const SizedBox(width: kWindowButtonWidth),
      ],
    );
  }
  return NavigationAppBar(
    actions: const WindowButtons(),
    automaticallyImplyLeading: false,
    title: title,
  );
}
