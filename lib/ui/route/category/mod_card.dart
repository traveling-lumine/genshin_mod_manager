import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/data/io/mod_switcher.dart';
import 'package:genshin_mod_manager/data/repo/akasha.dart';
import 'package:genshin_mod_manager/data/repo/filesystem_watcher.dart';
import 'package:genshin_mod_manager/domain/repo/app_state.dart';
import 'package:genshin_mod_manager/domain/repo/filesystem_watcher.dart';
import 'package:genshin_mod_manager/ui/route/category/editor_text.dart';
import 'package:genshin_mod_manager/ui/route/category/mod_card_vm.dart';
import 'package:genshin_mod_manager/ui/util/display_infobar.dart';
import 'package:logger/logger.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:provider/provider.dart';

class ModCard extends StatelessWidget {
  final String path;

  ModCard({
    required this.path,
  }) : super(key: Key(path));

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) => createFSEPathsWatcher<File>(
            targetPath: path,
            watcher: context.read(),
          ),
          dispose: (context, value) => value.dispose(),
        ),
        ChangeNotifierProvider(
          create: (context) => createModCardViewModel(),
        ),
      ],
      child: _ModCard(dirPath: path),
    );
  }
}

class _ModCard extends StatelessWidget {
  static const _minIniSectionWidth = 150.0;
  static final _logger = Logger();

  final _contextController = FlyoutController();
  final _contextAttachKey = GlobalKey();
  final String dirPath;

  _ModCard({required this.dirPath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: Card(
        backgroundColor: dirPath.pBasename.pIsEnabled
            ? Colors.green.lightest
            : Colors.red.lightest.withOpacity(0.5),
        padding: const EdgeInsets.all(6),
        child: FocusTraversalGroup(
          child: Column(
            children: [
              FutureBuilder(
                future: getFSEUnder<File>(dirPath),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Text('Loading...');
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
  }

  void buildErrorDialog(BuildContext context) {
    return errorDialog(
      context,
      'Failed to rename folder.'
      ' Check if the ShaderFixes folder is open in explorer,'
      ' and close it if it is.',
    );
  }

  void showDirectoryExists(BuildContext context, String renameTarget) {
    errorDialog(context, '${renameTarget.pBasename} directory already exists!');
  }

  void errorDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
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

  Widget _buildFolderHeader(BuildContext context, List<File> files) {
    // find config.json
    final File? findConfig = files.firstWhereOrNull(
      (element) => element.path.pBasename.pEquals(kAkashaConfigFilename),
    );
    return Row(
      children: [
        Expanded(
          child: Text(
            dirPath.pBasename.pEnabledForm,
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
            onPressed: () => openFolder(dirPath),
          ),
        ),
      ],
    );
  }

  Widget _buildFolderContent(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
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
  }

  Widget _buildDesc(BuildContext context, BoxConstraints constraints) {
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
              final filePath = dirPath.pJoin('preview.png');
              await File(filePath).writeAsBytes(image);
              if (!context.mounted) return;
              await displayInfoBar(
                context,
                builder: (_, close) {
                  return InfoBar(
                    title: const Text('Image pasted'),
                    content: Text('to $filePath'),
                    onClose: close,
                  );
                },
              );
              _logger.d('Image pasted to $filePath');
            },
            child: const Text('Paste'),
          ),
        )
      ],
    );
  }

  Widget _buildImageDesc(
      BuildContext context, BoxConstraints constraints, File previewFile) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: constraints.maxWidth - _minIniSectionWidth,
      ),
      child: GestureDetector(
        onTapUp: (details) {
          showDialog(
            context: context,
            builder: (context) {
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
        onSecondaryTapUp: (details) {
          final targetContext = _contextAttachKey.currentContext;
          if (targetContext == null) return;
          final box = targetContext.findRenderObject() as RenderBox;
          final position = box.localToGlobal(
            details.localPosition,
            ancestor: Navigator.of(context).context.findRenderObject(),
          );
          _contextController.showFlyout(
            position: position,
            builder: (context) => FlyoutContent(
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
  }

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
    final allFiles = getActiveiniFiles(dirPath);
    final List<Widget> alliniFile = [];
    for (final file in allFiles) {
      alliniFile.add(buildIniHeader(file));
      late String lastSection;
      bool metSection = false;
      file
          .readAsLinesSync(encoding: const Utf8Codec(allowMalformed: true))
          .forEach((line) {
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

  Widget buildIniHeader(File iniFile) {
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

  Widget buildIniFieldEditor(
      String data, String section, String line, File file) {
    return Row(
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
  }

  void _showDialog(BuildContext context, File previewFile) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context2) => ContentDialog(
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
                  builder: (context, close) => InfoBar(
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

  Future<void> _onRefresh(BuildContext context, File findConfig) async {
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
      await Directory(dirPath).delete(recursive: true);
      if (!context.mounted) throw Exception('context not mounted');
      await downloadFile(
          context, targetElement.title, download, dirPath.pDirname.pBasename);
      if (!context.mounted) return;
      unawaited(displayInfoBarInContext(
        context,
        title: const Text('Update downloaded'),
        content: Text('Update downloaded to ${dirPath.pDirname}'),
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

  void onTap(BuildContext context) {
    final isEnabled = dirPath.pBasename.pIsEnabled;
    final shaderFixesPath = context
        .read<AppStateService>()
        .modExecFile
        .latest
        .pDirname
        .pJoin(kShaderFixes);
    if (isEnabled) {
      disable(
        shaderFixesPath: shaderFixesPath,
        modPathW: dirPath,
        onModRenameClash: (p0) => showDirectoryExists(context, p0),
        onShaderDeleteFailed: (e) =>
            errorDialog(context, 'Failed to delete files in ShaderFixes: $e'),
        onModRenameFailed: () => buildErrorDialog(context),
      );
    } else {
      enable(
        shaderFixesPath: shaderFixesPath,
        modPath: dirPath,
        onModRenameClash: (p0) => showDirectoryExists(context, p0),
        onShaderExists: (e) =>
            errorDialog(context, '${e.path} already exists!'),
        onModRenameFailed: () => buildErrorDialog(context),
      );
    }
  }
}

Future<bool> downloadFile(BuildContext context, String filename, Uint8List data,
    String category) async {
  final modRoot = context.read<AppStateService>().modRoot.latest;
  if (modRoot == null) return false;
  final catPath = modRoot.pJoin(category);
  final enabledFormDirNames = (await getFSEUnder<Directory>(catPath))
      .map((e) => e.path.pBasename.pEnabledForm)
      .toSet();
  String destDirName = filename.pBNameWoExt.pEnabledForm;
  while (!destDirName.pIsEnabled) {
    destDirName = destDirName.pEnabledForm;
  }
  int counter = 0;
  String noCollisionDestDirName = destDirName;
  while (enabledFormDirNames.contains(noCollisionDestDirName)) {
    counter++;
    noCollisionDestDirName = '$destDirName ($counter)';
  }
  destDirName = noCollisionDestDirName.pDisabledForm;
  final destDirPath = catPath.pJoin(destDirName);
  await Directory(destDirPath).create(recursive: true);
  try {
    final archive = ZipDecoder().decodeBytes(data);
    await extractArchiveToDiskAsync(archive, destDirPath, asyncWrite: true);
  } on Exception {
    if (!context.mounted) return false;
    unawaited(displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: const Text('Download failed'),
          content: Text('Failed to extract archive: decode error.'
              ' Instead, the archive was saved as $filename.'),
          severity: InfoBarSeverity.error,
          onClose: close,
        );
      },
    ));
    try {
      await File(catPath.pJoin(filename)).writeAsBytes(data);
    } catch (e) {
      // duh
    }
    return false;
  }
  return true;
}
