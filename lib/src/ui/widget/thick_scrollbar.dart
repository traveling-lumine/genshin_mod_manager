import 'package:fluent_ui/fluent_ui.dart';

/// A widget that provides a thick scrollbar.
class ThickScrollbar extends StatelessWidget {
  /// Creates a [ThickScrollbar].
  const ThickScrollbar({
    required this.child,
    super.key,
  });

  /// The child of the scrollbar.
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    final current = FluentTheme.of(context);
    final isBright = current.brightness == Brightness.light;
    // higher contrast
    final toBeColor = isBright ? Colors.black : Colors.white;
    final scrollbarThemeData = ScrollbarThemeData(
      thickness: 8,
      hoveringThickness: 10,
      scrollbarColor: toBeColor,
    );
    return FluentTheme(
      data: current.copyWith(scrollbarTheme: scrollbarThemeData),
      child: child,
    );
  }
}

/// A widget that reverts the scrollbar to the default.
class RevertScrollbar extends StatelessWidget {
  /// Creates a [RevertScrollbar].
  const RevertScrollbar({
    required this.child,
    super.key,
  });

  /// The child of the scrollbar.
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    final brightness = FluentTheme.of(context).brightness;
    final toUse = brightness == Brightness.light
        ? FluentThemeData.light()
        : FluentThemeData.dark();
    return FluentTheme(
      // reverting thick scrollbar
      data: FluentTheme.of(context)
          .copyWith(scrollbarTheme: ScrollbarThemeData.standard(toUse)),
      child: child,
    );
  }
}
