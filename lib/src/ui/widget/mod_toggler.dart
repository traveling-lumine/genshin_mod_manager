import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app_config/l1/di/app_config_facade.dart';
import '../../app_config/l1/entity/entries.dart';
import '../../filesystem/l0/entity/mod.dart';
import '../../filesystem/l0/entity/mod_toggle_exceptions.dart';
import '../../filesystem/l1/impl/mod_switcher.dart';
import '../../filesystem/l1/impl/path_op_string.dart';

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
        onTap: () async => _onToggle(context, ref),
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
    final shaderFixesPath = ref
        .read(appConfigFacadeProvider)
        .obtainValue(games)
        .currentGameConfig
        .modExecFile
        ?.pDirname
        .pJoin(kShaderFixes);
    if (shaderFixesPath == null) {
      _showErrorDialog(context, 'ShaderFixes path not found');
      return;
    }
    try {
      await (mod.isEnabled ? disable : enable)(
        shaderFixesPath: shaderFixesPath,
        modPath: mod.path,
      );
    } on ModRenameClashException catch (e) {
      if (context.mounted) {
        _showDirectoryExistsDialog(context, e.renameTarget);
      }
    } on ModRenameFailedException {
      if (context.mounted) {
        _showRenameErrorDialog(context);
      }
    } on ShaderDeleteFailedException catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, 'Cannot delete ${e.path}');
      }
    } on ShaderExistsException catch (e) {
      if (context.mounted) {
        _showErrorDialog(context, '${e.path} already exists!');
      }
    }
  }

  void _showDirectoryExistsDialog(
    final BuildContext context,
    final String renameTarget,
  ) {
    _showErrorDialog(context, '$renameTarget directory already exists!');
  }

  void _showErrorDialog(final BuildContext context, final String text) {
    unawaited(
      showDialog(
        context: context,
        builder: (final dCtx) => ContentDialog(
          title: const Text('Error'),
          content: Text(text),
          actions: [
            FilledButton(
              onPressed: Navigator.of(dCtx).pop,
              child: const Text('Ok'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameErrorDialog(final BuildContext context) => _showErrorDialog(
      context,
      'Failed to rename folder.'
      ' Check if the ShaderFixes folder is open in explorer,'
      ' and close it if it is.');
}
