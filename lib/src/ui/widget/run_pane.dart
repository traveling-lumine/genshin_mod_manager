import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class RunAndExitPaneAction extends PaneItemAction {
  RunAndExitPaneAction({
    required super.icon,
    required Widget super.title,
    required Future<void> Function() super.onTap,
    super.key,
  }) : super(
          trailing: HookBuilder(
            builder: (final context) {
              final flyoutController = useFlyoutController();
              return FlyoutTarget(
                controller: flyoutController,
                child: IconButton(
                  icon: const Icon(FluentIcons.more),
                  onPressed: () =>
                      _showRunAndExitFlyout(flyoutController, onTap),
                ),
              );
            },
          ),
        );

  static Future<void> _showRunAndExitFlyout(
    final FlyoutController flyoutController,
    final Future<void> Function() onTap,
  ) async =>
      flyoutController.showFlyout(
        builder: (final context) => FlyoutContent(
          child: IntrinsicWidth(
            child: CommandBar(
              overflowBehavior: CommandBarOverflowBehavior.clip,
              primaryItems: [
                CommandBarButton(
                  icon: const Icon(FluentIcons.power_button),
                  label: const Text('Run and exit'),
                  onPressed: () async {
                    await onTap();
                    exit(0);
                  },
                ),
              ],
            ),
          ),
        ),
      );
}

FlyoutController useFlyoutController({final List<Object?>? keys}) =>
    use(_FlyoutControllerHook(keys: keys));

class _FlyoutControllerHook extends Hook<FlyoutController> {
  const _FlyoutControllerHook({super.keys});
  @override
  HookState<FlyoutController, Hook<FlyoutController>> createState() =>
      _FlyoutControllerHookState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}

class _FlyoutControllerHookState
    extends HookState<FlyoutController, _FlyoutControllerHook> {
  late final controller = FlyoutController();

  @override
  String get debugLabel => 'useFlyoutController';

  @override
  FlyoutController build(final BuildContext context) => controller;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<FlyoutController>('controller', controller));
  }

  @override
  void dispose() => controller.dispose();
}
