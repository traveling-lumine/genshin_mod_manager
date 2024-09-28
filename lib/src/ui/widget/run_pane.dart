import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

class RunAndExitPaneAction extends PaneItemAction {
  RunAndExitPaneAction({
    required super.icon,
    required Widget super.title,
    required Future<void> Function() super.onTap,
    required final FlyoutController flyoutController,
    super.key,
  }) : super(
          trailing: FlyoutTarget(
            controller: flyoutController,
            child: IconButton(
              icon: const Icon(FluentIcons.more),
              onPressed: () => _showRunAndExitFlyout(flyoutController, onTap),
            ),
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
