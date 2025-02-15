import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../util/eager_debounce_hook.dart';

class AutoResizeImage extends StatelessWidget {
  const AutoResizeImage({required this.image, required this.fit, super.key});
  final ImageProvider image;
  final BoxFit fit;

  @override
  Widget build(final BuildContext context) => LayoutBuilder(
        builder: (final lCtx, final constraints) => HookBuilder(
          builder: (final hCtx) {
            final debouncedWidth =
                useEagerDebounced(constraints.maxWidth.ceil());
            final debouncedHeight =
                useEagerDebounced(constraints.maxHeight.ceil());

            final resizeIfNeeded = ResizeImage(
              image,
              width: debouncedWidth,
              height: debouncedHeight,
              policy: ResizeImagePolicy.fit,
            );

            return Image(image: resizeIfNeeded, fit: fit);
          },
        ),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ImageProvider<Object>>('image', image))
      ..add(EnumProperty<BoxFit>('fit', fit));
  }
}
