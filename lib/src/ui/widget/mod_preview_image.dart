import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:window_manager/window_manager.dart';

import '../../fs_interface/di/fs_watcher.dart';
import '../util/debouncer.dart';
import '../util/third_party/time_aware_resize_image.dart' as s;

int _ceilToNextMultiple(final int value, final int multiple) =>
    (value + multiple - 1) ~/ multiple * multiple;

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
    final eventStream = ref.watch(
      fileEventWatcherProvider(widget.path, detectModifications: true),
    );

    final imageSize = useState<Size>(_getImageSize());
    useEffect(
      () {
        final subscription = eventStream.listen((final event) {
          _debouncer(() {
            if (File(widget.path).existsSync()) {
              imageSize.value = _getImageSize();
              _setCurMTime();
            }
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

        return HookBuilder(
          builder: (final context) {
            final debouncedWidth = _useEagerDebounced(cacheWidth);
            final debouncedHeight = _useEagerDebounced(cacheHeight);

            final resizeIfNeeded = s.ResizeImage.resizeIfNeeded(
              debouncedWidth,
              debouncedHeight,
              FileImage(File(widget.path)),
              _curMTime,
            );

            return Image(
              image: resizeIfNeeded,
              key: ValueKey(_curMTime),
              fit: widget.fit,
              frameBuilder: widget.frameBuilder,
            );
          },
        );
      },
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

  Size _getImageSize() => ImageSizeGetter.getSize(FileInput(File(widget.path)));

  int _getMTime() =>
      File(widget.path).lastModifiedSync().microsecondsSinceEpoch;

  void _setCurMTime() {
    setState(() => _curMTime = _getMTime());
  }
}

T? _useEagerDebounced<T>(final T toDebounce) => use(
      _EagerDebouncedHook(toDebounce: toDebounce),
    );

class _EagerDebouncedHook<T> extends Hook<T?> {
  const _EagerDebouncedHook({required this.toDebounce});
  final T toDebounce;

  @override
  _EagerDebouncedHookState<T> createState() => _EagerDebouncedHookState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<T>('toDebounce', toDebounce));
  }
}

class _EagerDebouncedHookState<T>
    extends HookState<T?, _EagerDebouncedHook<T>> {
  T? _state;
  Timer? _timer;

  @override
  String get debugLabel => 'useEagerDebounced<$T>';

  @override
  Object? get debugValue => _state;

  @override
  T? build(final BuildContext context) => _state;

  @override
  void didUpdateHook(final _EagerDebouncedHook<T> oldHook) {
    if (hook.toDebounce != oldHook.toDebounce) {
      _startDebounce(hook.toDebounce);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  void initHook() {
    super.initHook();
    _state = hook.toDebounce;
  }

  void _startDebounce(final T toDebounce) {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 400), () {
      setState(() => _state = toDebounce);
    });
  }
}
