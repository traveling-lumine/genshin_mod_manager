import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_config/l0/entity/entries.dart';
import '../../app_config/l1/di/app_config_facade.dart';
import '../../filesystem/l0/entity/mod.dart';
import '../../filesystem/l0/entity/mod_toggle_result.dart';
import '../../filesystem/l1/di/filesystem.dart';
import '../util/display_infobar.dart';

class ModToggler extends ConsumerWidget {
  const ModToggler({
    required this.child,
    required this.mod,
    super.key,
  });
  final Widget child;
  final Mod mod;

  @override
  Widget build(final BuildContext context, final WidgetRef ref) =>
      GestureDetector(
        onTap: () async {
          await _onToggle(context, ref);
        },
        child: child,
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Mod>('mod', mod));
  }

  Future<void> _onToggle(
    final BuildContext context,
    final WidgetRef ref,
  ) async {
    final currentGameConfig2 =
        ref.read(appConfigFacadeProvider).obtainValue(games).currentGameConfig;
    if (currentGameConfig2.modExecFile == null) {
      await _showErrorInfoBar(context, 'ShaderFixes path not found');
    }
    final fs = ref.read(filesystemProvider);
    ModToggleResult? toggleResult;
    try {
      toggleResult = await (mod.isEnabled ? fs.disable : fs.enable)(
        currentGameConfig2: currentGameConfig2,
        modPath: mod.path,
      );
    } on Exception catch (e) {
      if (context.mounted) {
        await _showErrorInfoBar(context, 'An unknown error occurred: $e');
      }
      return;
    }
    if (context.mounted) {
      switch (toggleResult) {
        case ModToggleResultModNotFound():
          await _showErrorInfoBar(context, 'Mod not found');
        case ModToggleResultAlreadyEnabled():
          await _showErrorInfoBar(context, 'Mod already enabled');
        case ModToggleResultAlreadyDisabled():
          await _showErrorInfoBar(context, 'Mod already disabled');
        case ModToggleResultModRenameClash(name: final renameTarget):
          await _showDirectoryExistsInfoBar(context, renameTarget);
        case ModToggleResultModRenameFailed():
          await _showRenameErrorInfoBar(context);
        case ModToggleResultModHasNoShaders():
          await _showErrorInfoBar(context, 'Mod has no shaders');
        case ModToggleResultShaderExists():
          await _showErrorInfoBar(context, 'Some shaders already exist');
        case ModToggleResultShaderCopyFailed():
          await _showErrorInfoBar(context, 'Failed to copy shaders');
        case ModToggleResultShaderDeleteFailed():
          await _showErrorInfoBar(context, 'Cannot delete shaders');
        case ModToggleResultShaderCleanupFailed():
          await _showErrorInfoBar(context, 'Failed to cleanup shaders');
        case ModToggleResultDone():
      }
    }
  }

  Future<void> _showDirectoryExistsInfoBar(
    final BuildContext context,
    final String renameTarget,
  ) =>
      _showErrorInfoBar(context, '$renameTarget directory already exists!');

  Future<void> _showErrorInfoBar(
    final BuildContext context,
    final String text,
  ) =>
      displayInfoBarInContext(
        context,
        title: const Text('Error'),
        content: Text(text),
        severity: InfoBarSeverity.error,
      );

  Future<void> _showRenameErrorInfoBar(final BuildContext context) =>
      displayInfoBarInContext(
        context,
        title: const Text('Error'),
        content: const Text('Failed to rename folder.'
            ' Check if the ShaderFixes folder is open in explorer,'
            ' and close it if it is.'),
        severity: InfoBarSeverity.error,
      );
}
