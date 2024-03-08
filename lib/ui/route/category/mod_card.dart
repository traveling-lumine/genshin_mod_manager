import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/data/upstream/akasha.dart';
import 'package:genshin_mod_manager/ui/route/category/editor_text.dart';
import 'package:genshin_mod_manager/ui/route/category/toggleable.dart';
import 'package:genshin_mod_manager/ui/route/nahida_store.dart';
import 'package:genshin_mod_manager/ui/service/folder_observer_service.dart';
import 'package:genshin_mod_manager/ui/widget/third_party/fluent_ui/red_filled_button.dart';
import 'package:logger/logger.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:provider/provider.dart';

class ModCard extends StatelessWidget {
  final String path;

  const ModCard({
    super.key,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<RecursiveObserverService,
        FileWatchService>(
      create: (context) => FileWatchService(targetPath: path),
      update: (context, value, previous) => previous!..update(value.lastEvent),
      child: _ModCard(
        dirPath: path,
      ),
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
    return ToggleableMod(
      dirPath: dirPath,
      child: Card(
        backgroundColor: dirPath.pBasename.pIsEnabled
            ? Colors.green.lightest
            : Colors.red.lightest.withOpacity(0.5),
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
  }

  Widget _buildFolderHeader(BuildContext context) {
    // find config.json
    final File? findConfig = getFSEUnder<File>(dirPath).firstWhereOrNull(
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
                try {
                  final recursiveObserverService =
                      context.read<RecursiveObserverService>();
                  final fileContent = await findConfig.readAsString();
                  final config = jsonDecode(fileContent);
                  final uuid = config['uuid'] as String;
                  final version = config['version'] as String;
                  final updateCode = config['update_code'] as String;
                  final api = NahidaliveAPI();
                  final targetElement = await api.fetchNahidaliveElement(uuid);
                  final upstreamVersion = targetElement.version;
                  if (version == upstreamVersion) {
                    if (!context.mounted) return;
                    unawaited(displayInfoBar(
                      context,
                      builder: (context, close) => InfoBar(
                        title: const Text('No update available'),
                        content: const Text('The mod is up to date'),
                        onClose: close,
                      ),
                    ));
                    return;
                  }
                  final downloadElement =
                      await api.downloadUrl(uuid, updateCode: updateCode);
                  final download = await api.download(downloadElement);

                  recursiveObserverService.cut();
                  await Directory(dirPath).delete(recursive: true);
                  if (!context.mounted) throw Exception('context not mounted');
                  await downloadFile(context, targetElement.title, download,
                      dirPath.pDirname.pBasename);
                  if (!context.mounted) return;
                  unawaited(displayInfoBar(
                    context,
                    builder: (context, close) {
                      return InfoBar(
                        title: const Text('Update downloaded'),
                        content:
                            Text('Update downloaded to ${dirPath.pDirname}'),
                        severity: InfoBarSeverity.success,
                        onClose: close,
                      );
                    },
                  ));
                  recursiveObserverService.uncut();
                  recursiveObserverService.forceUpdate();
                } catch (e) {
                  if (!context.mounted) return;
                  unawaited(displayInfoBar(
                    context,
                    builder: (context, close) => InfoBar(
                      title: const Text('Something went wrong'),
                      content: Text(e.toString()),
                      severity: InfoBarSeverity.error,
                      onClose: close,
                    ),
                  ));
                }
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
              _buildDesc(context, constraints),
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
    final v = context.watch<FileWatchService>().curEntities;
    final previewFile = findPreviewFileIn(v);
    if (previewFile == null) {
      return Expanded(
        child: Column(
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
        ),
      );
    }
    return _buildImageDesc(context, constraints, previewFile);
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
                onTap: () => Navigator.of(context).pop(),
                onSecondaryTap: () => Navigator.of(context).pop(),
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
          RedFilledButton(
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
        ],
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
}
