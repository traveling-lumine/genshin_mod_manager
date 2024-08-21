import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/di/fs_watcher.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TimeAwareFileImage extends ConsumerStatefulWidget {
  const TimeAwareFileImage({required this.path, super.key});

  final String path;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TimeAwareFileImageState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('path', path));
  }
}

class _TimeAwareFileImageState extends ConsumerState<TimeAwareFileImage> {
  int? _curMTime;

  @override
  Widget build(final BuildContext context) {
    ref.listen(
      fileEventSnapshotProvider(widget.path, true),
      (final previous, final next) async {
        if (previous == next) {
          return;
        }
        await FileImage(File(widget.path)).evict();
        if (!mounted) {
          return;
        }
        setState(() {
          _curMTime = DateTime.now().microsecondsSinceEpoch;
        });
      },
    );

    return Image.file(
      File(widget.path),
      key: ValueKey(_curMTime),
      fit: BoxFit.contain,
    );
  }
}
