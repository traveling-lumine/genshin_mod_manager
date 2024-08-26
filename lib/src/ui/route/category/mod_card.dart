import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pasteboard/pasteboard.dart';

import '../../../backend/fs_interface/data/helper/mod_switcher.dart';
import '../../../backend/fs_interface/data/helper/path_op_string.dart';
import '../../../backend/fs_interface/domain/entity/mod_toggle_exception.dart';
import '../../../backend/fs_interface/domain/usecase/file_system.dart';
import '../../../backend/fs_interface/domain/usecase/paste_image.dart';
import '../../../backend/structure/entity/ini.dart';
import '../../../backend/structure/entity/mod.dart';
import '../../../di/app_state/card_color.dart';
import '../../../di/app_state/game_config.dart';
import '../../../di/fs_interface.dart';
import '../../../di/mod_card.dart';
import '../../util/display_infobar.dart';
import '../../util/show_prompt_dialog.dart';
import '../../widget/custom_image.dart';
import 'ini_widget.dart';

class ModCard extends ConsumerStatefulWidget {
  const ModCard({required this.mod, super.key});
  final Mod mod;

  @override
  ConsumerState<ModCard> createState() => _ModCardState();

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Mod>('mod', mod));
  }
}

class _ModCardState extends ConsumerState<ModCard> {
  static const _minIniSectionWidth = 150.0;
  final _contextController = FlyoutController();
  final _contextAttachKey = GlobalKey();

  @override
  Widget build(final BuildContext context) => GestureDetector(
        onTap: _onToggle,
        child: Consumer(
          builder: (
            final context,
            final ref,
            final child,
          ) =>
              Card(
            backgroundColor: ref.watch(
              cardColorProvider(
                isBright:
                    FluentTheme.of(context).brightness == Brightness.light,
                isEnabled: widget.mod.isEnabled,
              ),
            ),
            padding: const EdgeInsets.all(6),
            child: child!,
          ),
          child: FocusTraversalGroup(
            child: Column(
              children: [
                _buildFolderHeader(),
                const SizedBox(height: 4),
                Expanded(child: _buildFolderContent()),
              ],
            ),
          ),
        ),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Mod>('mod', widget.mod));
  }

  @override
  void dispose() {
    _contextController.dispose();
    super.dispose();
  }

  Widget _buildDesc() => Consumer(
        builder: (final context, final ref, final child) {
          final preview = ref.watch(modIconPathProvider(widget.mod));
          if (preview == null) {
            return child!;
          }
          return _buildImageDesc(preview);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(FluentIcons.unknown),
            const SizedBox(height: 4),
            RepaintBoundary(
              child: Button(
                onPressed: _onPaste,
                child: const Text('Paste'),
              ),
            ),
          ],
        ),
      );

  Widget _buildFolderContent() => Consumer(
        builder: (final _, final ref, final child) {
          final iniPaths = ref.watch(iniPathsProvider(widget.mod));
          final isEmpty = iniPaths.isEmpty;
          return Row(
            mainAxisAlignment: isEmpty
                ? MainAxisAlignment.center
                : MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: child!),
              if (!isEmpty) _buildIni(iniPaths),
            ],
          );
        },
        child: Center(child: _buildDesc()),
      );

  Widget _buildFolderHeader() => Row(
        children: [
          Expanded(
            child: Text(
              widget.mod.displayName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
          ),
          _buildIconButton(
            icon: FluentIcons.command_prompt,
            onPressed: _onCommand,
          ),
          _buildIconButton(
            icon: FluentIcons.delete,
            onPressed: _onDeletePressed,
          ),
          _buildIconButton(
            icon: FluentIcons.folder_open,
            onPressed: _onFolderOpen,
          ),
        ],
      );

  Widget _buildIconButton({
    required final IconData icon,
    required final VoidCallback onPressed,
  }) =>
      RepaintBoundary(
        child: IconButton(icon: Icon(icon), onPressed: onPressed),
      );

  Widget _buildImageDesc(final String imagePath) => GestureDetector(
        onTapUp: (final details) async => _onImageTap(imagePath),
        onSecondaryTapUp: (final details) async =>
            _onImageRightClick(details, imagePath),
        child: FlyoutTarget(
          controller: _contextController,
          key: _contextAttachKey,
          child: TimeAwareFileImage(path: imagePath),
        ),
      );

  Widget _buildIni(final List<String> iniPaths) => Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Divider(direction: Axis.vertical),
          ),
          Card(
            backgroundColor: Colors.white.withOpacity(0.05),
            padding: const EdgeInsets.all(4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _minIniSectionWidth),
              child: ListView.builder(
                itemBuilder: (final context, final index) => IniWidget(
                  iniFile: IniFile(path: iniPaths[index], mod: widget.mod),
                ),
                itemCount: iniPaths.length,
              ),
            ),
          ),
        ],
      );

  Future<void> _onCommand() async {
    await ref.read(fsInterfaceProvider).openTerminal(widget.mod.path);
  }

  Future<void> _onDeletePressed() async {
    final userResponse = await showPromptDialog(
      context: context,
      title: 'Delete mod?',
      content: const Text('Are you sure you want to delete this mod?'),
      confirmButtonLabel: 'Delete',
      redButton: true,
    );
    if (!userResponse) {
      return;
    }
    Directory(widget.mod.path).deleteSync(recursive: true);
    if (mounted) {
      unawaited(
        displayInfoBarInContext(
          context,
          title: const Text('Mod deleted'),
          content: Text(
            'Mod deleted from ${widget.mod.path}',
          ),
          severity: InfoBarSeverity.warning,
        ),
      );
    }
  }

  Future<void> _onFolderOpen() async {
    final fsInterface = ref.read(fsInterfaceProvider);
    await openFolderUseCase(fsInterface, widget.mod.path);
  }

  Future<void> _onImageFlyoutDeletePressed(final BuildContext fCtx) async {
    final userResponse = await _showImageDeleteConfirmDialog();
    if (fCtx.mounted) {
      Navigator.of(fCtx).pop(userResponse);
    }
  }

  Future<void> _onImageRightClick(
    final TapUpDetails details,
    final String imagePath,
  ) async {
    final userResponse = await _showImageFlyout(details);
    if (userResponse != true) {
      return;
    }
    File(imagePath).deleteSync();
    if (mounted) {
      unawaited(
        displayInfoBarInContext(
          context,
          title: const Text('Preview deleted'),
          content: Text('Preview deleted from $imagePath'),
          severity: InfoBarSeverity.warning,
        ),
      );
    }
  }

  Future<void> _onImageTap(final String image) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (final dCtx) => GestureDetector(
        onTap: Navigator.of(dCtx).pop,
        onSecondaryTap: Navigator.of(dCtx).pop,
        child: TimeAwareFileImage(path: image),
      ),
    );
  }

  Future<void> _onPaste() async {
    final image = await Pasteboard.image;
    if (image == null) {
      return;
    }
    final fsInterface = ref.read(fsInterfaceProvider);
    await pasteImageUseCase(fsInterface, image, widget.mod);
    if (mounted) {
      unawaited(
        displayInfoBar(
          context,
          builder: (final _, final close) => InfoBar(
            title: const Text('Image pasted'),
            content: Text('to ${widget.mod.path}'),
            onClose: close,
          ),
        ),
      );
    }
  }

  Future<void> _onToggle() async {
    final shaderFixesPath = ref
        .read(gameConfigNotifierProvider)
        .modExecFile
        ?.pDirname
        .pJoin(kShaderFixes);
    if (shaderFixesPath == null) {
      _showErrorDialog('ShaderFixes path not found');
      return;
    }
    try {
      await (widget.mod.isEnabled ? disable : enable)(
        shaderFixesPath: shaderFixesPath,
        modPath: widget.mod.path,
      );
    } on ModRenameClashException catch (e) {
      if (mounted) {
        _showDirectoryExistsDialog(context, e.renameTarget);
      }
    } on ModRenameFailedException {
      if (mounted) {
        _showRenameErrorDialog();
      }
    } on ShaderDeleteFailedException catch (e) {
      if (mounted) {
        _showErrorDialog('Cannot delete ${e.path}');
      }
    } on ShaderExistsException catch (e) {
      if (mounted) {
        _showErrorDialog('${e.path} already exists!');
      }
    }
  }

  void _showDirectoryExistsDialog(
    final BuildContext context,
    final String renameTarget,
  ) {
    _showErrorDialog(
      '$renameTarget directory already exists!',
    );
  }

  void _showErrorDialog(final String text) {
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

  Future<bool> _showImageDeleteConfirmDialog() => showPromptDialog(
        context: context,
        title: 'Delete preview image?',
        content: const Text(
          'Are you sure you want to delete the preview image?',
        ),
        confirmButtonLabel: 'Delete',
        redButton: true,
      );

  Future<bool?> _showImageFlyout(
    final TapUpDetails details,
  ) async {
    final targetContext = _contextAttachKey.currentContext;
    if (targetContext == null) {
      return null;
    }
    final box = targetContext.findRenderObject()! as RenderBox;
    final position = box.localToGlobal(
      details.localPosition,
      ancestor: Navigator.of(context).context.findRenderObject(),
    );

    return _contextController.showFlyout<bool?>(
      position: position,
      builder: (final fCtx) => FlyoutContent(
        child: IntrinsicWidth(
          child: CommandBar(
            overflowBehavior: CommandBarOverflowBehavior.clip,
            primaryItems: [
              CommandBarButton(
                icon: const Icon(FluentIcons.delete),
                label: const Text('Delete'),
                onPressed: () async => _onImageFlyoutDeletePressed(fCtx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRenameErrorDialog() => _showErrorDialog(
        'Failed to rename folder.'
        ' Check if the ShaderFixes folder is open in explorer,'
        ' and close it if it is.',
      );
}
