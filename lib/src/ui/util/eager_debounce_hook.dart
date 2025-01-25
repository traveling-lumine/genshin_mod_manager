import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

T? useEagerDebounced<T>(final T toDebounce) => use(
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
