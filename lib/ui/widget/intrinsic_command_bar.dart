import 'package:fluent_ui/fluent_ui.dart';

class IntrinsicCommandBarCard extends StatelessWidget {

  const IntrinsicCommandBarCard({
    required this.child, super.key,
  });
  final Widget child;

  @override
  Widget build(final BuildContext context) => IntrinsicCommandBar(
      child: CommandBarCard(
        child: child,
      ),
    );
}

class IntrinsicCommandBar extends StatelessWidget {

  const IntrinsicCommandBar({
    required this.child, super.key,
  });
  final Widget child;

  @override
  Widget build(final BuildContext context) => IntrinsicWidth(
      child: RepaintBoundary(
        child: child,
      ),
    );
}
