import 'package:fluent_ui/fluent_ui.dart';

/// A card that is used to wrap the [CommandBar] to make it
/// have an intrinsic width.
class IntrinsicCommandBarCard extends StatelessWidget {
  /// Creates a card that is used to wrap the [CommandBar] to make it
  const IntrinsicCommandBarCard({
    required this.child,
    super.key,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(final BuildContext context) => IntrinsicWidth(
        child: CommandBarCard(
          child: RepaintBoundary(
            child: child,
          ),
        ),
      );
}
