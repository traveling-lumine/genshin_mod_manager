import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';

import '../../di/fs_watcher.dart';
import '../util/debouncer.dart';
import '../util/third_party/time_aware_resize_image.dart'
    as third_party_image_provider;

int _ceilToNextMultiple(final int value, final int multiple) =>
    (value + multiple - 1) ~/ multiple * multiple;

class ModPreviewImage extends HookConsumerWidget {
  ModPreviewImage({
    required this.path,
    super.key,
    this.frameBuilder,
    this.fit = BoxFit.contain,
  });
  final String path;
  final BoxFit fit;
  final ImageFrameBuilder? frameBuilder;
  final _debouncer = Debouncer(const Duration(milliseconds: 300));

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final eventStream = ref.watch(
      fileEventWatcherProvider(path, detectModifications: true),
    );

    final imageSize = useState<Size>(_getImageSize());
    final curMTime = useState<int>(_getMTime());
    useEffect(
      () {
        final subscription = eventStream.listen((final event) {
          _debouncer(() {
            imageSize.value = _getImageSize();
            curMTime.value = _getMTime();
          });
        });
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

        final resizeIfNeeded =
            third_party_image_provider.ResizeImage.resizeIfNeeded(
          cacheWidth,
          cacheHeight,
          FileImage(File(path)),
          curMTime.value,
        );

        return Image(
          image: resizeIfNeeded,
          fit: fit,
          frameBuilder: frameBuilder,
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

  Size _getImageSize() => ImageSizeGetter.getSize(FileInput(File(path)));

  int _getMTime() => File(path).lastModifiedSync().microsecondsSinceEpoch;
}
