import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';

import '../../di/fs_watcher.dart';

class ModPreviewImage extends HookConsumerWidget {
  const ModPreviewImage({
    required this.path,
    super.key,
    this.frameBuilder,
    this.fit = BoxFit.contain,
  });
  final String path;
  final BoxFit fit;
  final ImageFrameBuilder? frameBuilder;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final curMTime = useState<int>(DateTime.now().microsecondsSinceEpoch);
    final imageSize =
        useState<Size>(ImageSizeGetter.getSize(FileInput(File(path))));

    final eventStream =
        ref.watch(fileEventWatcherProvider(path, detectModifications: true));

    useEffect(
      () {
        final subscription = eventStream.listen(
          (final event) async {
            await FileImage(File(path)).evict();
            curMTime.value = DateTime.now().microsecondsSinceEpoch;
            imageSize.value = ImageSizeGetter.getSize(FileInput(File(path)));
          },
        );

        return subscription.cancel;
      },
      [eventStream],
    );

    return LayoutBuilder(
      builder: (final context, final constraints) {
        final candidateWidth = constraints.maxWidth.ceil();
        final candidateHeight = constraints.maxHeight.ceil();
        final candidateAspectRatio = candidateWidth / candidateHeight;

        final imageSize_ = imageSize.value;
        final imageWidth = imageSize_.width;
        final imageHeight = imageSize_.height;
        final imageAspectRatio = imageWidth / imageHeight;

        const ceilConstant = 16;
        final cacheWidth = imageAspectRatio < candidateAspectRatio
            ? null
            : _ceilToNextMultiple(candidateWidth, ceilConstant);
        final cacheHeight = imageAspectRatio < candidateAspectRatio
            ? _ceilToNextMultiple(candidateHeight, ceilConstant)
            : null;

        return Image.file(
          File(path),
          key: ValueKey(curMTime.value),
          fit: fit,
          frameBuilder: frameBuilder,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
        );
      },
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('path', path))
      ..add(EnumProperty<BoxFit?>('fit', fit))
      ..add(
        ObjectFlagProperty<ImageFrameBuilder?>.has(
          'frameBuilder',
          frameBuilder,
        ),
      );
  }
}

int _ceilToNextMultiple(final int value, final int multiple) =>
    (value + multiple - 1) ~/ multiple * multiple;
