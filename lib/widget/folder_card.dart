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
                  final file = widget.dirPath
                      .join(const PathString('preview.png'))
                      .toFile;
                  await file.writeAsBytes(image);
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
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: constraints.maxWidth - minIniSectionWidth,
      ),
      child: Image.file(
        previewFile,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
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
