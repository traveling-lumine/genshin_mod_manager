import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../app_config/l0/entity/entries.dart';
import '../../app_config/l0/usecase/change_app_config.dart';
import '../../app_config/l1/di/app_config.dart';
import '../../app_config/l1/di/app_config_facade.dart';
import '../../app_config/l1/di/app_config_persistent_repo.dart';

class PersistentWindowSizeWidget extends HookConsumerWidget
    with WindowListener {
  const PersistentWindowSizeWidget({required this.child, super.key});
  final Widget child;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    useEffect(
      () {
        final listener = _ProtocolListenerWrapper(ref);
        WindowManager.instance.addListener(listener);
        final read = ref.read(appConfigFacadeProvider).obtainValue(windowSize);
        if (read != null) {
          unawaited(WindowManager.instance.setSize(read));
        }
        return () {
          WindowManager.instance.removeListener(listener);
        };
      },
      [ref],
    );
    return child;
  }
}

class _ProtocolListenerWrapper with WindowListener {
  _ProtocolListenerWrapper(this.ref);
  final WidgetRef ref;

  @override
  void onWindowResized() {
    super.onWindowResized();
    unawaited(_saveNewWindowSize());
  }

  Future<void> _saveNewWindowSize() async {
    final newSize = await WindowManager.instance.getSize();
    final newState = changeAppConfigUseCase(
      appConfigFacade: ref.read(appConfigFacadeProvider),
      appConfigPersistentRepo: ref.read(appConfigPersistentRepoProvider),
      entry: windowSize,
      value: newSize,
    );
    ref.read(appConfigCProvider.notifier).setData(newState);
  }
}
