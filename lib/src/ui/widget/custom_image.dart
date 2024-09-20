import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../di/fs_watcher.dart';

class TimeAwareFileImage extends ConsumerStatefulWidget {
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
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TimeAwareFileImageState();

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

class _TimeAwareFileImageState extends ConsumerState<TimeAwareFileImage> {
  int? _curMTime;

  @override
  Widget build(final BuildContext context) {
    ref.listen(
        fileEventSnapshotProvider(widget.path, detectModifications: true),
        (final previous, final next) async {
      if (previous == next) {
        return;
      }
      await FileImage(File(widget.path)).evict();
      if (mounted) {
        setState(() {
          _curMTime = DateTime.now().microsecondsSinceEpoch;
        });
      }
    });

    return Image.file(
      File(widget.path),
      key: ValueKey(_curMTime),
      fit: widget.fit,
      frameBuilder: widget.frameBuilder,
    );
  }
}
