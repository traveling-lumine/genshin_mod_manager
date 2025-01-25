import 'dart:ui' as p;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../util/eager_debounce_hook.dart';

class AutoResizeImage extends StatefulWidget {
  const AutoResizeImage({required this.image, required this.fit, super.key});
  final ImageProvider image;
  final BoxFit fit;

  @override
  State<AutoResizeImage> createState() => _AutoResizeImageState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ImageProvider<Object>>('image', image))
      ..add(EnumProperty<BoxFit>('fit', fit));
  }
}

class _AutoResizeImageState extends State<AutoResizeImage> {
  double? _imageAspectRatio;

  @override
  void initState() {
    super.initState();
    widget.image.resolve(ImageConfiguration.empty).addListener(
      ImageStreamListener((final info, final _) {
        final p.Image(:width, :height) = info.image;
        setState(() => _imageAspectRatio = width / height);
      }),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final imageAspectRatio = _imageAspectRatio;
    if (imageAspectRatio == null) {
      return const Center(child: ProgressRing());
    }
    return LayoutBuilder(
      builder: (final context, final constraints) {
        final candidateWidth = constraints.maxWidth.ceil();
        final candidateHeight = constraints.maxHeight.ceil();
        final candidateAspectRatio = candidateWidth / candidateHeight;

        const ceilConstant = 16;
        final cacheWidth = imageAspectRatio < candidateAspectRatio
            ? null
            : _ceilToNextMultiple(candidateWidth, ceilConstant);
        final cacheHeight = imageAspectRatio < candidateAspectRatio
            ? _ceilToNextMultiple(candidateHeight, ceilConstant)
            : null;

        return HookBuilder(
          builder: (final context) {
            final debouncedWidth = useEagerDebounced(cacheWidth);
            final debouncedHeight = useEagerDebounced(cacheHeight);

            final resizeIfNeeded = ResizeImage.resizeIfNeeded(
              debouncedWidth,
              debouncedHeight,
              widget.image,
            );

            return Image(
              image: resizeIfNeeded,
              fit: widget.fit,
            );
          },
        );
      },
    );
  }
}

int _ceilToNextMultiple(final int value, final int multiple) =>
    (value + multiple - 1) ~/ multiple * multiple;
