import 'package:fluent_ui/fluent_ui.dart';

class ThickScrollbar extends StatelessWidget {
  const ThickScrollbar({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
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
      data: current.copyWith(
        scrollbarTheme: scrollbarThemeData,
      ),
      child: child,
    );
  }
}

class RevertScrollbar extends StatelessWidget {
  const RevertScrollbar({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = FluentTheme.of(context).brightness;
    final toUse = brightness == Brightness.light
        ? FluentThemeData.light()
        : FluentThemeData.dark();
    return FluentTheme(
      // reverting thick scrollbar
      data: FluentTheme.of(context).copyWith(
        scrollbarTheme: ScrollbarThemeData.standard(toUse),
      ),
      child: child,
    );
  }
}
