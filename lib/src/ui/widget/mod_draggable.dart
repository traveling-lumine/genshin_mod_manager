import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';

import '../../filesystem/l0/entity/mod.dart';

class ModDraggable extends StatelessWidget {
  const ModDraggable({
    required this.mod,
    required this.child,
    super.key,
  });
  final Mod mod;
  final Widget child;

  @override
  Widget build(final BuildContext context) => LongPressDraggable<Mod>(
        data: mod,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: Card(
          backgroundColor:
              FluentTheme.of(context).brightness == Brightness.light
                  ? Colors.grey[30]
                  : Colors.grey[150],
          borderColor: Colors.blue,
          child: Text(mod.displayName),
        ),
        child: child,
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Mod>('mod', mod));
  }
}
