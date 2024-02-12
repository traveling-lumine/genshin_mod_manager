import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

const kWindowButtonWidth = 138.0;

NavigationAppBar getAppbar(String text) {
  return NavigationAppBar(
    actions: const WindowButtons(),
    automaticallyImplyLeading: false,
    title: DragToMoveArea(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text),
      ),
    ),
  );
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: kWindowButtonWidth,
      height: 50,
      child: WindowCaption(),
    );
  }
}
