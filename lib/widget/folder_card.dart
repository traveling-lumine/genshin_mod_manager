import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/base/directory_watch_widget.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/io/fsops.dart';
import 'package:genshin_mod_manager/widget/editor_text.dart';
import 'package:genshin_mod_manager/widget/folder_toggle.dart';
import 'package:logger/logger.dart';
import 'package:pasteboard/pasteboard.dart';

class FolderCard extends DirectoryWatchWidget {
  FolderCard({required super.dirPath}) : super(key: ValueKey(dirPath));

  @override
  DWState<FolderCard> createState() => _FolderCardState();
}

class _FolderCardState extends DWState<FolderCard> {
  static const minIniSectionWidth = 150;
  static final logger = Logger();

  final contextController = FlyoutController();
  final contextAttachKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final dirPath = widget.dirPath;
    final basename = dirPath.basename;
    final isEnabled = basename.isEnabled;
    final color = isEnabled
        ? Colors.green.lightest
        : Colors.red.lightest.withOpacity(0.5);

    return FolderToggle(
      dirPath: dirPath,
      child: Card(
        backgroundColor: color,
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            buildFolderHeader(context),
            const SizedBox(height: 4),
            buildFolderContent(context),
          ],
        ),
      ),
    );
  }

  Widget buildFolderHeader(BuildContext context) {
    final dirPath = widget.dirPath;
    return Row(
      children: [
        Expanded(
          child: Text(
            dirPath.basename.enabledForm.asString,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: FluentTheme.of(context).typography.bodyStrong,
          ),
        ),
        const SizedBox(width: 4),
        Button(
          child: const Icon(FluentIcons.folder_open),
          onPressed: () => openFolder(dirPath.toDirectory),
        ),
      ],
    );
  }

  Widget buildFolderContent(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildDesc(context, constraints),
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

  Widget buildDesc(BuildContext context, BoxConstraints constraints) {
    final previewFile = findPreviewFile(widget.dirPath.toDirectory);
    if (previewFile == null) {
      return Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(FluentIcons.unknown),
            const SizedBox(height: 4),
            Button(
              onPressed: () async {
                final image = await Pasteboard.image;
                if (image != null) {
                  final file =
                      widget.dirPath.join(const PathW('preview.png')).toFile;
                  await file.writeAsBytes(image);
                  if (!mounted) return;
                  await displayInfoBar(
                    context,
                    builder: (_, close) {
                      return InfoBar(
                        title: const Text('Image pasted'),
                        content: Text('to ${file.path}'),
                        onClose: close,
                      );
                    },
                  );
                  logger.d('Image pasted to ${file.path}');
                } else {
                  logger.d('No image found in clipboard');
                }
              },
              child: const Text('Paste'),
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
        maxWidth: constraints.maxWidth - minIniSectionWidth,
      ),
      child: GestureDetector(
        onTapUp: (details) {
          showDialog(
            context: context,
            builder: (context) {
              FileImage(previewFile).evict();
              // add touch to close
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                onSecondaryTap: () => Navigator.of(context).pop(),
                child: Image.file(
                  previewFile,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ),
              );
            },
          );
        },
        onSecondaryTapUp: (details) {
          final targetContext = contextAttachKey.currentContext;
          if (targetContext == null) return;
          final box = targetContext.findRenderObject() as RenderBox;
          final position = box.localToGlobal(
            details.localPosition,
            ancestor: Navigator.of(context).context.findRenderObject(),
          );
          contextController.showFlyout(
            position: position,
            builder: (context) {
              return FlyoutContent(
                child: SizedBox(
                  width: 120,
                  child: CommandBar(
                    primaryItems: [
                      CommandBarButton(
                        icon: const Icon(FluentIcons.delete),
                        label: const Text('Delete'),
                        onPressed: () {
                          // show alert dialog
                          showDialog(
                            context: context,
                            builder: (context) {
                              return ContentDialog(
                                title: const Text('Delete preview image?'),
                                content: const Text(
                                    'Are you sure you want to delete the preview image?'),
                                actions: [
                                  Button(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  Button(
                                    // red button
                                    style: ButtonStyle(
                                      backgroundColor:
                                          ButtonState.resolveWith((states) {
                                        final res =
                                            FluentTheme.of(context).resources;
                                        final color = Colors.red;
                                        const t = 0.8;
                                        if (states.isPressing) {
                                          return res.controlFillColorTertiary
                                              .lerpWith(color, t);
                                        } else if (states.isHovering) {
                                          return res.controlFillColorSecondary
                                              .lerpWith(color, t);
                                        } else if (states.isDisabled) {
                                          return res.controlFillColorDisabled
                                              .lerpWith(color, t);
                                        }
                                        return res.controlFillColorDefault
                                            .lerpWith(color, t);
                                      }),
                                    ),
                                    child: const Text('Delete'),
                                    onPressed: () async {
                                      previewFile.deleteSync();
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      displayInfoBar(
                                        context,
                                        builder: (context, close) {
                                          return InfoBar(
                                            title:
                                                const Text('Preview deleted'),
                                            content: Text(
                                                'Preview deleted from ${previewFile.path}'),
                                            severity: InfoBarSeverity.warning,
                                            onClose: close,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: FlyoutTarget(
          controller: contextController,
          key: contextAttachKey,
          child: () {
            FileImage(previewFile).evict();
            return Image.file(
              previewFile,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
            );
          }(),
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
    final allFiles = getActiveiniFiles(widget.dirPath.toDirectory);
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
    final basenameString = iniFile.basename.asString;
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
        Button(
          child: const Icon(FluentIcons.document_management),
          onPressed: () => runProgram(iniFile),
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

  @override
  bool shouldUpdate(FileSystemEvent event) => true;

  @override
  void updateFolder() => setState(() {});
}
