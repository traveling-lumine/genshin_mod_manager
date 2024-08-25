import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_converter/flutter_image_converter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pasteboard/pasteboard.dart';

import '../../../backend/fs_interface/data/helper/mod_switcher.dart';
import '../../../backend/fs_interface/data/helper/path_op_string.dart';
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
  void dispose() {
    _contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => GestureDetector(
        onTap: _onToggle,
        child: Card(
          backgroundColor: ref.watch(
            cardColorProvider(
              isBright: FluentTheme.of(context).brightness == Brightness.light,
              isEnabled: widget.mod.isEnabled,
            ),
          ),
          padding: const EdgeInsets.all(6),
          child: FocusTraversalGroup(
            child: Column(
              children: [
                _buildFolderHeader(),
                const SizedBox(height: 4),
                _buildFolderContent(),
              ],
            ),
          ),
        ),
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
          RepaintBoundary(
            child: IconButton(
              icon: const Icon(FluentIcons.command_prompt),
              onPressed: _onCommand,
            ),
          ),
          RepaintBoundary(
            child: IconButton(
              icon: const Icon(FluentIcons.delete),
              onPressed: _onDeletePressed,
            ),
          ),
          RepaintBoundary(
            child: IconButton(
              icon: const Icon(FluentIcons.folder_open),
              onPressed: () async {
                final fsInterface = ref.read(fsInterfaceProvider);
                await fsInterface.openFolder(widget.mod.path);
              },
            ),
          ),
        ],
      );

  Widget _buildFolderContent() => Expanded(
        child: LayoutBuilder(
          builder: (final context, final constraints) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDesc(context, constraints),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Divider(direction: Axis.vertical),
              ),
              _buildIni(),
            ],
          ),
        ),
      );

  Widget _buildIni() => Consumer(
        builder: (final context, final ref, final child) {
          final iniPaths = ref.watch(iniPathsProvider(widget.mod));
          return Expanded(
            child: iniPaths.isNotEmpty
                ? Card(
                    backgroundColor: Colors.white.withOpacity(0.05),
                    padding: const EdgeInsets.all(4),
                    child: ListView.builder(
                      itemBuilder: (final context, final index) {
                        final path = iniPaths[index];
                        return IniWidget(
                          iniFile: IniFile(path: path, mod: widget.mod),
                        );
                      },
                      itemCount: iniPaths.length,
                    ),
                  )
                : const Center(
                    child: Text('No ini files found'),
                  ),
          );
        },
      );

  Widget _buildDesc(
    final BuildContext context,
    final BoxConstraints constraints,
  ) =>
      Consumer(
        builder: (final context, final ref, final child) {
          final preview = ref.watch(modIconPathProvider(widget.mod));
          if (preview == null) {
            return Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FluentIcons.unknown),
                  const SizedBox(height: 4),
                  RepaintBoundary(
                    child: Button(
                      onPressed: () => unawaited(_onPaste(context)),
                      child: const Text('Paste'),
                    ),
                  ),
                ],
              ),
            );
          }
          return _buildImageDesc(context, constraints, preview);
        },
      );

  Widget _buildImageDesc(
    final BuildContext context,
    final BoxConstraints constraints,
    final String imagePath,
  ) =>
      ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: constraints.maxWidth - _minIniSectionWidth,
        ),
        child: GestureDetector(
          onTapUp: (final details) async => _onImageTap(imagePath),
          onSecondaryTapUp: (final details) async =>
              _onImageRightClick(details, context, imagePath),
          child: FlyoutTarget(
            controller: _contextController,
            key: _contextAttachKey,
            child: TimeAwareFileImage(path: imagePath),
          ),
        ),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Mod>('mod', widget.mod));
  }

  Future<void> _onPaste(final BuildContext context) async {
    final image = await Pasteboard.image;
    if (image == null) {
      return;
    }
    final filePath = widget.mod.path.pJoin('preview.png');
    final bytes = await image.pngUint8List;
    await File(filePath).writeAsBytes(bytes);
    if (!context.mounted) {
      return;
    }
    await displayInfoBar(
      context,
      builder: (final _, final close) => InfoBar(
        title: const Text('Image pasted'),
        content: Text('to $filePath'),
        onClose: close,
      ),
    );
    return;
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

  Future<void> _onImageRightClick(
    final TapUpDetails details,
    final BuildContext context,
    final String imagePath,
  ) async {
    final targetContext = _contextAttachKey.currentContext;
    if (targetContext == null) {
      return;
    }
    final box = targetContext.findRenderObject()! as RenderBox;
    final position = box.localToGlobal(
      details.localPosition,
      ancestor: Navigator.of(context).context.findRenderObject(),
    );

    final userResponse = await _contextController.showFlyout<bool?>(
      position: position,
      builder: (final fCtx) => FlyoutContent(
        child: IntrinsicWidth(
          child: CommandBar(
            overflowBehavior: CommandBarOverflowBehavior.clip,
            primaryItems: [
              CommandBarButton(
                icon: const Icon(FluentIcons.delete),
                label: const Text('Delete'),
                onPressed: () async {
                  final userResponse = await showPromptDialog(
                    context: fCtx,
                    title: 'Delete preview image?',
                    content: const Text(
                      'Are you sure you want to delete the preview image?',
                    ),
                    confirmButtonLabel: 'Delete',
                    redButton: true,
                  );
                  if (context.mounted) {
                    Navigator.of(fCtx).pop(userResponse);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
    if (userResponse != true) {
      return;
    }
    File(imagePath).deleteSync();
    if (context.mounted) {
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

  void _onToggle() {
    final shaderFixesPath = ref
        .read(gameConfigNotifierProvider)
        .modExecFile
        ?.pDirname
        .pJoin(kShaderFixes);
    if (shaderFixesPath == null) {
      _errorDialog(context, 'ShaderFixes path not found');
      return;
    }
    if (widget.mod.isEnabled) {
      unawaited(
        disable(
          shaderFixesPath: shaderFixesPath,
          modPath: widget.mod.path,
          onModRenameClash: (final p0) => _showDirectoryExists(context, p0),
          onShaderDeleteFailed: (final e) => _errorDialog(
            context,
            'Failed to delete files in ShaderFixes: $e',
          ),
          onModRenameFailed: () => _showErrorDialog(context),
        ),
      );
    } else {
      unawaited(
        enable(
          shaderFixesPath: shaderFixesPath,
          modPath: widget.mod.path,
          onModRenameClash: (final p0) => _showDirectoryExists(context, p0),
          onShaderExists: (final e) =>
              _errorDialog(context, '${e.path} already exists!'),
          onModRenameFailed: () => _showErrorDialog(context),
        ),
      );
    }
  }

  void _showErrorDialog(final BuildContext context) => _errorDialog(
        context,
        'Failed to rename folder.'
        ' Check if the ShaderFixes folder is open in explorer,'
        ' and close it if it is.',
      );

  void _showDirectoryExists(
    final BuildContext context,
    final String renameTarget,
  ) {
    _errorDialog(
      context,
      '${renameTarget.pBasename} directory already exists!',
    );
  }

  void _errorDialog(final BuildContext context, final String text) {
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

  Future<void> _onCommand() async {
    await ref.read(fsInterfaceProvider).openTerminal(widget.mod.path);
  }
}
