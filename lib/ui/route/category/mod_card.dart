import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_converter/flutter_image_converter.dart';
import 'package:genshin_mod_manager/data/helper/mod_switcher.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/data/repo/akasha.dart';
import 'package:genshin_mod_manager/data/repo/mod_writer.dart';
import 'package:genshin_mod_manager/di/app_state.dart';
import 'package:genshin_mod_manager/di/fs_interface.dart';
import 'package:genshin_mod_manager/di/mod_card.dart';
import 'package:genshin_mod_manager/domain/entity/ini.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/ui/route/category/ini_widget.dart';
import 'package:genshin_mod_manager/ui/util/display_infobar.dart';
import 'package:genshin_mod_manager/ui/widget/custom_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:pasteboard/pasteboard.dart';

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
  static final _logger = Logger();
  final _contextController = FlyoutController();
  final _contextAttachKey = GlobalKey();

  @override
  void dispose() {
    _contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => GestureDetector(
        onTap: () => _onToggle(context),
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
                _buildFolderHeader(context),
                const SizedBox(height: 4),
                _buildFolderContent(context),
              ],
            ),
          ),
        ),
      );

  Widget _buildFolderHeader(final BuildContext context) => Consumer(
        builder: (final context, final ref, final child) {
          final value = ref.watch(configPathProvider(widget.mod));
          return Row(
            children: [
              Expanded(
                child: Text(
                  widget.mod.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FluentTheme.of(context).typography.bodyStrong,
                ),
              ),
              if (value != null) ...[
                RepaintBoundary(
                  child: IconButton(
                    icon: const Icon(FluentIcons.refresh),
                    onPressed: () async => _onRefresh(context, value),
                  ),
                ),
              ],
              RepaintBoundary(
                child: IconButton(
                  icon: const Icon(FluentIcons.delete),
                  onPressed: () {
                    _onDeletePressed(context);
                  },
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
        },
      );

  Widget _buildFolderContent(final BuildContext context) => Expanded(
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
          onTapUp: (final details) async => _onImageTap(context, imagePath),
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
      _logger.d('No image found in clipboard');
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
    _logger.d('Image pasted to $filePath');
    return;
  }

  void _onDeletePressed(final BuildContext context) => unawaited(
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (final dCtx) => ContentDialog(
            title: const Text('Delete mod?'),
            content: const Text(
              'Are you sure you want to delete this mod?',
            ),
            actions: [
              Button(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(dCtx);
                },
              ),
              FluentTheme(
                data: FluentTheme.of(context).copyWith(
                  accentColor: Colors.red,
                ),
                child: FilledButton(
                  child: const Text('Delete'),
                  onPressed: () {
                    Navigator.pop(dCtx);
                    Directory(widget.mod.path).deleteSync(
                      recursive: true,
                    );
                    displayInfoBarInContext(
                      context,
                      title: const Text('Mod deleted'),
                      content: Text(
                        'Mod deleted from ${widget.mod.path}',
                      ),
                      severity: InfoBarSeverity.warning,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );

  Future<void> _onImageTap(
    final BuildContext context,
    final String image,
  ) async {
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

    await _contextController.showFlyout<void>(
      position: position,
      builder: (final fCtx) => FlyoutContent(
        child: IntrinsicWidth(
          child: CommandBar(
            overflowBehavior: CommandBarOverflowBehavior.clip,
            primaryItems: [
              CommandBarButton(
                icon: const Icon(FluentIcons.delete),
                label: const Text('Delete'),
                onPressed: () => _onImageDelete(context, imagePath),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onImageDelete(final BuildContext context, final String imagePath) {
    unawaited(
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (final dCtx) => ContentDialog(
          title: const Text('Delete preview image?'),
          content:
              const Text('Are you sure you want to delete the preview image?'),
          actions: [
            Button(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dCtx).pop();
                Navigator.of(context).pop();
              },
            ),
            FluentTheme(
              data: FluentTheme.of(context).copyWith(accentColor: Colors.red),
              child: FilledButton(
                onPressed: () {
                  File(imagePath).deleteSync();
                  Navigator.of(dCtx).pop();
                  Navigator.of(context).pop();
                  displayInfoBarInContext(
                    context,
                    title: const Text('Preview deleted'),
                    content: Text('Preview deleted from $imagePath'),
                    severity: InfoBarSeverity.warning,
                  );
                },
                child: const Text('Delete'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onRefresh(
    final BuildContext context,
    final String findConfig,
  ) async {
    try {
      final fileContent = await File(findConfig).readAsString();
      final config = jsonDecode(fileContent) as Map<String, dynamic>;
      final uuid = config['uuid'] as String;
      final version = config['version'] as String;
      final updateCode = config['update_code'] as String;
      final api = createNahidaliveAPI();
      final targetElement = await api.fetchNahidaliveElement(uuid);
      final upstreamVersion = targetElement.version;
      if (version == upstreamVersion) {
        if (!context.mounted) {
          return;
        }
        unawaited(
          displayInfoBarInContext(
            context,
            title: const Text('No update available'),
            content: const Text('The mod is up to date'),
          ),
        );
        return;
      }
      final downloadElement =
          await api.downloadUrl(uuid, updateCode: updateCode);
      final data = await api.download(downloadElement);

      try {
        Directory(widget.mod.path).deleteSync(recursive: true);
        final writer = createModWriter(category: widget.mod.category);
        await writer.write(
          modName: targetElement.title,
          data: data,
        );
        if (!context.mounted) {
          return;
        }
        unawaited(
          displayInfoBarInContext(
            context,
            title: const Text('Update downloaded'),
            content: Text('Update downloaded to ${widget.mod.path.pDirname}'),
            severity: InfoBarSeverity.success,
          ),
        );
      } finally {}
    } on FormatException catch (e) {
      if (!context.mounted) {
        return;
      }
      unawaited(
        displayInfoBarInContext(
          context,
          title: const Text('Something went wrong'),
          content: Text(e.toString()),
          severity: InfoBarSeverity.error,
        ),
      );
    }
  }

  void _onToggle(final BuildContext context) {
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
        builder: (final context) => ContentDialog(
          title: const Text('Error'),
          content: Text(text),
          actions: [
            FilledButton(
              child: const Text('Ok'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
