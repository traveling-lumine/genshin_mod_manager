import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../filesystem/l1/di/file_event.dart';
import '../util/time_aware_image.dart';
import 'auto_resize_image.dart';

class LatestImage extends HookConsumerWidget {
  const LatestImage({
    required this.path,
    super.key,
    this.fit = BoxFit.contain,
  });
  final String path;
  final BoxFit fit;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final curMTime = useState(_getMTime());
    ref.listen(fileEventDebouncedProvider(path: path),
        (final previous, final next) {
      if (next.hasValue && File(path).existsSync()) {
        curMTime.value = _getMTime();
      }
    });

    final value = curMTime.value;
    if (value == null) {
      return const SizedBox.shrink();
    }
    return AutoResizeImage(
      image: TimeAwareImage(FileImage(File(path)), mTime: value),
      fit: fit,
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('path', path))
      ..add(EnumProperty<BoxFit>('fit', fit));
  }

  int? _getMTime() {
    try {
      return File(path).lastModifiedSync().microsecondsSinceEpoch;
    } on PathNotFoundException {
      return null;
    }
  }
}
