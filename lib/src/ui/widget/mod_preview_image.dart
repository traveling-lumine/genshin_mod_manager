import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../filesystem/l1/di/file_event.dart';
import '../util/time_aware_resize_image.dart' as s;
import '../util/debouncer.dart';
import 'auto_resize_image.dart';

class ModPreviewImage extends StatefulHookConsumerWidget {
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
  ConsumerState<ModPreviewImage> createState() => _ModPreviewImageState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('path', path))
      ..add(EnumProperty<BoxFit>('fit', fit))
      ..add(
        ObjectFlagProperty<ImageFrameBuilder?>.has(
          'frameBuilder',
          frameBuilder,
        ),
      );
  }
}

class _ModPreviewImageState extends ConsumerState<ModPreviewImage>
    with WindowListener {
  final _debouncer = Debouncer(const Duration(milliseconds: 300));
  late int _curMTime = _getMTime();

  @override
  Widget build(final BuildContext context) {
    final evtWatcher = ref.watch(
      fileEventProvider(path: widget.path),
    );

    useEffect(
      () {
        final subscription = evtWatcher.stream.listen((final event) {
          _debouncer(() {
            if (File(widget.path).existsSync()) {
              _setCurMTime();
            }
          });
        });
        return subscription.cancel;
      },
      [evtWatcher],
    );

    return AutoResizeImage(
      image: s.TimeAwareImage(FileImage(File(widget.path)), mTime: _curMTime),
      fit: widget.fit,
    );
  }

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('path', widget.path))
      ..add(EnumProperty<BoxFit?>('fit', widget.fit))
      ..add(
        ObjectFlagProperty<ImageFrameBuilder?>.has(
          'frameBuilder',
          widget.frameBuilder,
        ),
      );
  }

  @override
  void dispose() {
    WindowManager.instance.removeListener(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WindowManager.instance.addListener(this);
  }

  @override
  void onWindowFocus() {
    super.onWindowFocus();
    _setCurMTime();
  }

  int _getMTime() =>
      File(widget.path).lastModifiedSync().microsecondsSinceEpoch;

  void _setCurMTime() {
    if (!mounted) {
      return;
    }
    setState(() {
      if (File(widget.path).existsSync()) {
        _curMTime = _getMTime();
      }
    });
  }
}
