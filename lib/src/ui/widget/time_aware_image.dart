import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../di/fs_watcher.dart';

class TimeAwareFileImage extends HookConsumerWidget {
  const TimeAwareFileImage({
    required this.path,
    super.key,
    this.frameBuilder,
    this.fit = BoxFit.contain,
  });
  final String path;
  final BoxFit? fit;
  final ImageFrameBuilder? frameBuilder;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final curMTime = useState<int>(DateTime.now().microsecondsSinceEpoch);

    final eventStream =
        ref.watch(fileEventWatcherProvider(path, detectModifications: true));

    useEffect(
      () {
        final subscription = eventStream.listen(
          (final event) async {
            await FileImage(File(path)).evict();
            curMTime.value = DateTime.now().microsecondsSinceEpoch;
          },
        );

        return subscription.cancel;
      },
      [eventStream],
    );

    return Image.file(
      File(path),
      key: ValueKey(curMTime.value),
      fit: fit,
      frameBuilder: frameBuilder,
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
