import 'package:fluent_ui/fluent_ui.dart';

class ThickScrollbar extends StatelessWidget {
  const ThickScrollbar({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FluentTheme(
      data: FluentThemeData(
        scrollbarTheme: ScrollbarThemeData(
          thickness: 8,
          hoveringThickness: 10,
          scrollbarColor: Colors.grey[140],
        ),
      ),
      child: child,
    );
  }
}
