import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:protocol_handler/protocol_handler.dart';

import '../../app_config/l1/di/exe_arg.dart';

class ProtocolUrlForwardWidget extends HookConsumerWidget {
  const ProtocolUrlForwardWidget({required this.child, super.key});
  final Widget child;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    useEffect(
      () {
        final listener = _ProtocolListenerWrapper(ref);
        protocolHandler.addListener(listener);
        return () => protocolHandler.removeListener(listener);
      },
      [ref],
    );
    return child;
  }
}

class _ProtocolListenerWrapper with ProtocolListener {
  _ProtocolListenerWrapper(this.ref);
  final WidgetRef ref;

  @override
  void onProtocolUrlReceived(final String url) {
    ref.read(argProviderProvider.notifier).add(url);
  }
}
