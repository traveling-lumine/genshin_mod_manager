import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../filesystem/l1/di/filesystem.dart';

class WindowListenerWidget extends ConsumerStatefulWidget {
  const WindowListenerWidget({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<WindowListenerWidget> createState() =>
      _WindowListenerWidgetState();
}

class _WindowListenerWidgetState extends ConsumerState<WindowListenerWidget>
    with WindowListener {
  @override
  void initState() {
    super.initState();
    WindowManager.instance.addListener(this);
  }

  @override
  void dispose() {
    WindowManager.instance.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowBlur() {
    super.onWindowBlur();
    unawaited(ref.read(filesystemProvider).pauseAllWatchers());
  }

  @override
  void onWindowFocus() {
    super.onWindowFocus();
    ref.read(filesystemProvider).resumeAllWatchers();
  }

  @override
  Widget build(final BuildContext context) => widget.child;
}
