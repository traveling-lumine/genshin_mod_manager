import 'package:fluent_ui/fluent_ui.dart';

class IntrinsicCommandBarCard extends StatelessWidget {
  final Widget child;

  const IntrinsicCommandBarCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicCommandBar(
      child: CommandBarCard(
        child: child,
      ),
    );
  }
}

class IntrinsicCommandBar extends StatelessWidget {
  final Widget child;

  const IntrinsicCommandBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: RepaintBoundary(
        child: child,
      ),
    );
  }
}
