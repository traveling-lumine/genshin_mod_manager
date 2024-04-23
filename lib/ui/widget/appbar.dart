import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/ui/widget/preset_control.dart';
import 'package:window_manager/window_manager.dart';

/// The width of window control button row.
const _kWindowButtonWidth = 138.0;

/// A widget that provides a navigation appbar.
NavigationAppBar getAppbar(
  final String text, {
  final bool presetControl = false,
}) {
  Widget title = DragToMoveArea(
    child: Align(
      alignment: Alignment.centerLeft,
      child: Builder(
        builder: (final context) => DefaultTextStyle(
          style: TextStyle(
            color: FluentTheme.of(context).brightness == Brightness.light
                ? Colors.black.withOpacity(0.8956)
                : Colors.white,
            fontSize: 14,
          ),
          child: Text(text),
        ),
      ),
    ),
  );
  if (presetControl) {
    title = Stack(
      alignment: Alignment.centerLeft,
      children: [
        title,
        Positioned(
          right: _kWindowButtonWidth,
          child: PresetControlWidget(isLocal: false),
        ),
      ],
    );
  }
  return NavigationAppBar(
    actions: SizedBox(
      width: _kWindowButtonWidth,
      height: 50,
      child: RepaintBoundary(
        child: Builder(
          builder: (final context) => WindowCaption(
            brightness: FluentTheme.of(context).brightness,
          ),
        ),
      ),
    ),
    automaticallyImplyLeading: false,
    title: title,
  );
}
