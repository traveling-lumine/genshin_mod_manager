import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/base/directory_watch_widget.dart';
import 'package:genshin_mod_manager/io/fsops.dart';
import 'package:genshin_mod_manager/provider/app_state.dart';
import 'package:genshin_mod_manager/window/widget/editor_text.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

class FolderCard extends DirectoryWatchWidget {
  FolderCard({required super.dirPath}) : super(key: ValueKey(dirPath));

  @override
  DWState<FolderCard> createState() => _FolderCardState();
}

class _FolderCardState extends DWState<FolderCard> {
  static final Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    String displayName = p.basename(widget.dir.path);
    final isDisabled = displayName.startsWith('DISABLED ');
    final color = isDisabled
        ? Colors.red.lightest.withOpacity(0.5)
        : Colors.green.lightest;
    if (isDisabled) {
      displayName = displayName.substring(9);
    }

    return GestureDetector(
      onTap: () {
        if (isDisabled) {
          toggleEnable(context, displayName);
        } else {
          toggleDisable(context, displayName);
        }
      },
      child: Card(
        backgroundColor: color,
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            buildFolderHeader(context, displayName),
            const SizedBox(height: 4),
            buildFolderContent(context, displayName),
          ],
        ),
      ),
    );
  }

  Widget buildFolderHeader(BuildContext context, String displayName) {
    return Row(
      children: [
        Expanded(
          child: Text(
            displayName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: FluentTheme.of(context).typography.bodyStrong,
          ),
        ),
        const SizedBox(width: 4),
        Button(
          child: const Icon(FluentIcons.folder_open),
          onPressed: () => openFolder(widget.dir),
        ),
      ],
    );
  }

  Widget buildFolderContent(BuildContext context, String displayName) {
    return Expanded(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildDesc(context, displayName, constraints),
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

  Widget buildDesc(
      BuildContext context, String folderName, BoxConstraints constraints) {
    final previewFile = findPreviewFile(widget.dir);
    if (previewFile == null) {
      return const Expanded(child: Center(child: Icon(FluentIcons.unknown)));
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: constraints.maxWidth - 150,
      ),
      child: Image.file(
        previewFile,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }

  Widget buildIni() {
    final alliniFile = allFilesToWidget(getActiveiniFiles(widget.dir));
    return Expanded(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 80,
        ),
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
      ),
    );
  }

  void toggleEnable(BuildContext context, String displayName) {
    final List<File> shaderFilenames = [];
    try {
      Directory(p.join(widget.dirPath, 'ShaderFixes'))
          .listSync()
          .forEach((element) {
        if (element is File) {
          shaderFilenames.add(element);
        }
      });
    } on PathNotFoundException catch (e) {
      logger.i(e);
      return;
    }

    final String renameTarget = p.join(widget.dir.parent.path, displayName);
    if (Directory(renameTarget).existsSync()) {
      showDirectoryExists(context, renameTarget);
      return;
    }
    try {
      if (shaderFilenames.isNotEmpty) {
        final tgt = p.join(context.read<AppState>().targetDir, 'ShaderFixes');
        copyShaders(tgt, shaderFilenames);
      }
    } on FileSystemException catch (e) {
      logger.w(e);
      showUnableCopy(context, e.path!);
      return;
    }
    widget.dir.renameSync(renameTarget);
    return;
  }

  void toggleDisable(BuildContext context, String displayName) {
    final String renameTarget;

    // list all files in the folder
    List<File> shaderFilenames = [];
    try {
      Directory('${widget.dir}\\ShaderFixes').listSync().forEach((element) {
        if (element is File) {
          shaderFilenames.add(element);
        }
      });
    } catch (e) {
      logger.i(e);
    }

    final shaderFixDir = '${context.read<AppState>().targetDir}\\ShaderFixes';

    renameTarget = '${widget.dir.parent.path}\\DISABLED $displayName';
    if (Directory(renameTarget).existsSync()) {
      showDirectoryExists(context, renameTarget);
      return;
    }
    try {
      if (shaderFilenames.isNotEmpty) {
        deleteShaders(shaderFixDir, shaderFilenames);
      }
    } catch (e) {
      logger.w(e);
      showUnableDelete(context);
      return;
    }
    widget.dir.renameSync(renameTarget);
    return;
  }

  void copyShaders(String targetDir, List<File> shaderFiles) {
    // check for existence first
    Directory(targetDir).listSync().forEach((e) {
      for (var e2 in shaderFiles) {
        final last2 = e.path.split('\\').last;
        if (last2 == e2.path.split('\\').last) {
          throw FileSystemException(
            'Target directory is not empty',
            last2,
          );
        }
      }
    });
    for (final element in shaderFiles) {
      element.copySync('$targetDir\\${element.path.split('\\').last}');
    }
  }

  void deleteShaders(String targetDir, List<File> shaderFilenames) {
    Directory(targetDir).listSync().forEach((e) {
      if (e is File) {
        final any = shaderFilenames.any((e2) {
          return e.path.split('\\').last == e2.path.split('\\').last;
        });
        if (any) {
          e.deleteSync();
        }
      }
    });
  }

  void showUnableDelete(BuildContext context) {
    errorDialog(context, 'Failed to delete files in ShaderFixes');
  }

  void showUnableCopy(BuildContext context, String filename) {
    errorDialog(context, '$filename already exists!');
  }

  void showDirectoryExists(BuildContext context, String renameTarget) {
    renameTarget = p.basename(renameTarget);
    errorDialog(context, '$renameTarget already exists!');
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

  @override
  bool shouldUpdate(FileSystemEvent event) {
    return true;
  }

  @override
  void updateFolder() {
    setState(() {});
  }
}

List<Widget> allFilesToWidget(List<File> allFiles) {
  List<Widget> alliniFile = [];
  for (var i = 0; i < allFiles.length; i++) {
    final cur = allFiles[i];
    alliniFile.add(buildIniHeader(cur));
    late String lastSection;
    bool metSection = false;
    cur.readAsLinesSync().forEach((line) {
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
        alliniFile.add(buildIniFieldEditor('key:', lastSection, line, cur));
      } else if (lineLower.startsWith('back')) {
        alliniFile.add(buildIniFieldEditor('back:', lastSection, line, cur));
      } else if (line.startsWith('\$') && metSection) {
        final cycles = ','.allMatches(line.split(';').first).length + 1;
        alliniFile.add(Text('Cycles: $cycles'));
      }
    });
  }
  return alliniFile;
}

Widget buildIniHeader(File iniFile) {
  final iniName = p.basename(iniFile.path);
  return Row(
    children: [
      Expanded(
        child: Tooltip(
          message: iniName,
          child: Text(
            iniName,
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
