import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/data/extension/path_op_string.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/data/io/mod_switcher.dart';
import 'package:genshin_mod_manager/data/repo/akasha.dart';
import 'package:genshin_mod_manager/data/repo/filesystem_watcher.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/domain/repo/app_state.dart';
import 'package:genshin_mod_manager/domain/repo/filesystem_watcher.dart';
import 'package:genshin_mod_manager/ui/route/category/editor_text.dart';
import 'package:genshin_mod_manager/ui/route/category/mod_card_vm.dart';
import 'package:genshin_mod_manager/ui/util/display_infobar.dart';
import 'package:logger/logger.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:provider/provider.dart';

class ModCard extends StatelessWidget {
  final Mod mod;

  ModCard({
    required this.mod,
  }) : super(key: Key(mod.path));

  @override
  Widget build(final BuildContext context) => MultiProvider(
        providers: [
          Provider(
            create: (final context) => createFSEPathsWatcher<File>(
              targetPath: mod.path,
              watcher: context.read(),
            ),
            dispose: (final context, final value) => value.dispose(),
          ),
          ChangeNotifierProvider(
            create: (final context) => createModCardViewModel(),
          ),
        ],
        child: _ModCard(mod: mod),
      );
}

class _ModCard extends StatelessWidget {
  static const _minIniSectionWidth = 150.0;
  static final _logger = Logger();

  final _contextController = FlyoutController();
  final _contextAttachKey = GlobalKey();
  final Mod mod;

  _ModCard({required this.mod});

  @override
  Widget build(final BuildContext context) => GestureDetector(
        onTap: () => _onToggle(context),
        child: Card(
          backgroundColor: mod.isEnabled
              ? Colors.green.lightest
              : Colors.red.lightest.withOpacity(0.5),
          padding: const EdgeInsets.all(6),
          child: FocusTraversalGroup(
            child: Column(
              children: [
                FutureBuilder(
                  // ignore: discarded_futures
                  future: getUnder<File>(mod.path),
                  builder: (final context, final snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Text('Loading...');
                    }
                    return _buildFolderHeader(context, data);
                  },
                ),
                const SizedBox(height: 4),
                _buildFolderContent(context),
              ],
            ),
          ),
        ),
      );

  void buildErrorDialog(final BuildContext context) => errorDialog(
        context,
        'Failed to rename folder.'
        ' Check if the ShaderFixes folder is open in explorer,'
        ' and close it if it is.',
      );

  void showDirectoryExists(
      final BuildContext context, final String renameTarget) {
    errorDialog(context, '${renameTarget.pBasename} directory already exists!');
  }

  void errorDialog(final BuildContext context, final String text) {
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
    );
  }

  Widget _buildFolderHeader(
      final BuildContext context, final List<File> files) {
    // find config.json
    final File? findConfig = files.firstWhereOrNull(
      (final element) => element.path.pBasename.pEquals(kAkashaConfigFilename),
    );
    return Row(
      children: [
        Expanded(
          child: Text(
            mod.displayName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: FluentTheme.of(context).typography.bodyStrong,
          ),
        ),
        if (findConfig != null) ...[
          const SizedBox(width: 4),
          RepaintBoundary(
            child: Button(
              child: const Icon(FluentIcons.refresh),
              onPressed: () async {
                await _onRefresh(context, findConfig);
              },
            ),
          ),
        ],
        const SizedBox(width: 4),
        RepaintBoundary(
          child: Button(
            child: const Icon(FluentIcons.folder_open),
            onPressed: () => openFolder(mod.path),
          ),
        ),
      ],
    );
  }

  Widget _buildFolderContent(final BuildContext context) => Expanded(
        child: LayoutBuilder(
          builder:
              (final BuildContext context, final BoxConstraints constraints) {
            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: _buildDesc(context, constraints)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Divider(direction: Axis.vertical),
                ),
                buildIni(),
              ],
            );
          },
        ),
      );

  Widget _buildDesc(
      final BuildContext context, final BoxConstraints constraints) {
    final v = context.watch<FSEPathsWatcher>().paths.latest;
    final previewFile = findPreviewFileInString(v);
    if (previewFile != null) {
      return _buildImageDesc(context, constraints, File(previewFile));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(FluentIcons.unknown),
        const SizedBox(height: 4),
        RepaintBoundary(
          child: Button(
            onPressed: () async {
              final image = await Pasteboard.image;
              if (image == null) {
                _logger.d('No image found in clipboard');
                return;
              }
              final filePath = mod.path.pJoin('preview.png');
              await File(filePath).writeAsBytes(image);
              if (!context.mounted) return;
              await displayInfoBar(
                context,
                builder: (final _, final close) => InfoBar(
                  title: const Text('Image pasted'),
                  content: Text('to $filePath'),
                  onClose: close,
                ),
              );
              _logger.d('Image pasted to $filePath');
            },
            child: const Text('Paste'),
          ),
        )
      ],
    );
  }

  Widget _buildImageDesc(final BuildContext context,
          final BoxConstraints constraints, final File previewFile) =>
      ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: constraints.maxWidth - _minIniSectionWidth,
        ),
        child: GestureDetector(
          onTapUp: (final details) {
            showDialog(
              context: context,
              builder: (final context) {
                // add touch to close
                return GestureDetector(
                  onTap: Navigator.of(context).pop,
                  onSecondaryTap: Navigator.of(context).pop,
                  child: Image.memory(
                    previewFile.readAsBytesSync(),
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.medium,
                  ),
                );
              },
            );
          },
          onSecondaryTapUp: (final details) {
            final targetContext = _contextAttachKey.currentContext;
            if (targetContext == null) return;
            final box = targetContext.findRenderObject() as RenderBox;
            final position = box.localToGlobal(
              details.localPosition,
              ancestor: Navigator.of(context).context.findRenderObject(),
            );
            _contextController.showFlyout(
              position: position,
              builder: (final context) => FlyoutContent(
                child: SizedBox(
                  width: 120,
                  child: CommandBar(
                    primaryItems: [
                      CommandBarButton(
                        icon: const Icon(FluentIcons.delete),
                        label: const Text('Delete'),
                        onPressed: () => _showDialog(context, previewFile),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          child: FlyoutTarget(
            controller: _contextController,
            key: _contextAttachKey,
            child: Image.memory(
              previewFile.readAsBytesSync(),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      );

  Widget buildIni() {
    final alliniFile = allFilesToWidget();
    return Expanded(
      child: alliniFile.isNotEmpty
          ? Card(
              backgroundColor: Colors.white.withOpacity(0.4),
              padding: const EdgeInsets.all(4),
              child: ListView(
                children: alliniFile,
              ),
            )
          : const Center(
              child: Text('No ini files found'),
            ),
    );
  }

  List<Widget> allFilesToWidget() {
    final allFiles = getActiveiniFiles(mod.path);
    final List<Widget> alliniFile = [];
    for (final file in allFiles) {
      alliniFile.add(buildIniHeader(file));
      late String lastSection;
      bool metSection = false;
      file
          .readAsLinesSync(encoding: const Utf8Codec(allowMalformed: true))
          .forEach((final line) {
        if (line.startsWith('[')) {
          metSection = false;
        }
        final regExp = RegExp(r'\[Key.*?\]');
        final match = regExp.firstMatch(line)?.group(0)!;
        if (match != null) {
          alliniFile.add(Text(match));
          lastSection = match;
          metSection = true;
        }
        final lineLower = line.toLowerCase();
        if (lineLower.startsWith('key')) {
          alliniFile.add(buildIniFieldEditor('key:', lastSection, line, file));
        } else if (lineLower.startsWith('back')) {
          alliniFile.add(buildIniFieldEditor('back:', lastSection, line, file));
        } else if (line.startsWith('\$') && metSection) {
          final cycles = ','.allMatches(line.split(';').first).length + 1;
          alliniFile.add(Text('Cycles: $cycles'));
        }
      });
    }
    return alliniFile;
  }

  Widget buildIniHeader(final File iniFile) {
    final basenameString = iniFile.path.pBasename;
    return Row(
      children: [
        Expanded(
          child: Tooltip(
            message: basenameString,
            child: Text(
              basenameString,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        RepaintBoundary(
          child: Button(
            child: const Icon(FluentIcons.document_management),
            onPressed: () => runProgram(iniFile),
          ),
        ),
      ],
    );
  }

  Widget buildIniFieldEditor(final String data, final String section,
          final String line, final File file) =>
      Row(
        children: [
          Text(data),
          Expanded(
            child: EditorText(
              section: section,
              line: line,
              file: file,
            ),
          ),
        ],
      );

  void _showDialog(final BuildContext context, final File previewFile) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (final context2) => ContentDialog(
        title: const Text('Delete preview image?'),
        content:
            const Text('Are you sure you want to delete the preview image?'),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context2).pop();
              Navigator.of(context).pop();
            },
          ),
          FluentTheme(
            data: FluentTheme.of(context).copyWith(accentColor: Colors.red),
            child: FilledButton(
              onPressed: () {
                previewFile.deleteSync();
                Navigator.of(context2).pop();
                Navigator.of(context).pop();
                displayInfoBar(
                  context,
                  builder: (final context, final close) => InfoBar(
                    title: const Text('Preview deleted'),
                    content: Text('Preview deleted from ${previewFile.path}'),
                    severity: InfoBarSeverity.warning,
                    onClose: close,
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh(
      final BuildContext context, final File findConfig) async {
    try {
      final recursiveObserverService =
          context.read<RecursiveFileSystemWatcher>();
      final fileContent = await findConfig.readAsString();
      final config = jsonDecode(fileContent);
      final uuid = config['uuid'] as String;
      final version = config['version'] as String;
      final updateCode = config['update_code'] as String;
      final api = createNahidaliveAPI();
      final targetElement = await api.fetchNahidaliveElement(uuid);
      final upstreamVersion = targetElement.version;
      if (version == upstreamVersion) {
        if (!context.mounted) return;
        unawaited(displayInfoBarInContext(
          context,
          title: const Text('No update available'),
          content: const Text('The mod is up to date'),
        ));
        return;
      }
      final downloadElement =
          await api.downloadUrl(uuid, updateCode: updateCode);
      final download = await api.download(downloadElement);

      recursiveObserverService.cut();
      await Directory(mod).delete(recursive: true);
      if (!context.mounted) throw Exception('context not mounted');
      await downloadFile(
          context, targetElement.title, download, mod.pDirname.pBasename);
      if (!context.mounted) return;
      unawaited(displayInfoBarInContext(
        context,
        title: const Text('Update downloaded'),
        content: Text('Update downloaded to ${mod.pDirname}'),
        severity: InfoBarSeverity.success,
      ));
      recursiveObserverService.uncut();
      recursiveObserverService.forceUpdate();
    } catch (e) {
      if (!context.mounted) return;
      unawaited(displayInfoBarInContext(
        context,
        title: const Text('Something went wrong'),
        content: Text(e.toString()),
        severity: InfoBarSeverity.error,
      ));
    }
  }

  void _onToggle(final BuildContext context) {
    final isEnabled = mod.pBasename.pIsEnabled;
    final shaderFixesPath = context
        .read<AppStateService>()
        .modExecFile
        .latest
        .pDirname
        .pJoin(kShaderFixes);
    if (isEnabled) {
      disable(
        shaderFixesPath: shaderFixesPath,
        modPathW: mod,
        onModRenameClash: (final p0) => showDirectoryExists(context, p0),
        onShaderDeleteFailed: (final e) =>
            errorDialog(context, 'Failed to delete files in ShaderFixes: $e'),
        onModRenameFailed: () => buildErrorDialog(context),
      );
    } else {
      enable(
        shaderFixesPath: shaderFixesPath,
        modPath: mod,
        onModRenameClash: (final p0) => showDirectoryExists(context, p0),
        onShaderExists: (final e) =>
            errorDialog(context, '${e.path} already exists!'),
        onModRenameFailed: () => buildErrorDialog(context),
      );
    }
  }
}
