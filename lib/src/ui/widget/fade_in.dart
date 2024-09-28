import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

class FadeInWidget extends StatelessWidget {
  const FadeInWidget({
    required this.child,
    required this.fadeTarget,
    required this.visible,
    super.key,
    this.duration = const Duration(milliseconds: 200),
  });

  final Widget child;
  final Widget fadeTarget;
  final Duration duration;
  final bool visible;

  @override
  Widget build(final BuildContext context) => Stack(
        children: [
          child,
          Positioned.fill(
            child: AnimatedOpacity(
              duration: duration,
              opacity: visible ? 1.0 : 0.0,
              child: _buildFadeTarget(),
            ),
          ),
        ],
      );

  Widget? _buildFadeTarget() => visible
      ? Acrylic(
          blurAmount: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: fadeTarget),
          ),
        )
      : null;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Duration>('duration', duration))
      ..add(DiagnosticsProperty<bool>('visible', visible));
  }
}
