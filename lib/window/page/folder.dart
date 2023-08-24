import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/io/fsops.dart';
import 'package:genshin_mod_manager/new_impl/min_extent_delegate.dart';
import 'package:genshin_mod_manager/provider/app_state.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

class FolderPage extends StatefulWidget {
  final Directory dir;

  FolderPage({
    required this.dir,
  }) : super(key: ValueKey(dir.path));

  @override
  State<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  static final Logger logger = Logger();
  late StreamSubscription<FileSystemEvent> subscription;
  late List<Directory> allChildrenFolder;

  @override
  void initState() {
    super.initState();
    final dir = widget.dir;
    onDirChange(dir);
  }

  @override
  void didUpdateWidget(covariant FolderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldDir = oldWidget.dir;
    final newDir = widget.dir;
    if (oldDir == newDir) return;
    logger.i('Directory changed from $oldDir to $newDir');
    subscription.cancel();
    onDirChange(newDir);
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text(p.basename(widget.dir.path)),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.folder_open),
              onPressed: () {
                openFolder(widget.dir);
              },
            ),
          ],
        ),
      ),
      content: GridView(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithMinCrossAxisExtent(
          minCrossAxisExtent: 350,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          mainAxisExtent: 420,
        ),
        children: allChildrenFolder.map((e) => FolderCard(e)).toList(),
      ),
    );
  }

  void onDirChange(Directory newDir) {
    updateFolder(newDir);
    subscription =
        newDir.watch().listen((event) {
          if (event is FileSystemModifyEvent && event.contentChanged) {
            logger.i('Ignoring content change event: $event');
            return;
          }
          setState(() => updateFolder(newDir));
        });
  }

  void updateFolder(Directory dir) {
    allChildrenFolder = getAllChildrenFolder(dir)..sort(folderSorter);
  }

  int folderSorter(a, b) {
    var aName = p.basename(a.path);
    var bName = p.basename(b.path);
    aName = aName.startsWith('DISABLED ') ? aName.substring(9) : aName;
    bName = bName.startsWith('DISABLED ') ? bName.substring(9) : bName;
    return aName.toLowerCase().compareTo(bName.toLowerCase());
  }
}

class FolderCard extends StatelessWidget {
  static final Logger logger = Logger();
  final Directory e;

  const FolderCard(
    this.e, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    String folderName = p.basename(e.path);
    final isDisabled = folderName.startsWith('DISABLED ');
    final color = isDisabled
        ? Colors.red.lightest.withOpacity(0.5)
        : Colors.green.lightest;
    if (isDisabled) {
      folderName = folderName.substring(9);
    }

    return GestureDetector(
      onTap: () {
        final String renameTarget;

        // list all files in the folder
        List<File> shaderFilenames = [];
        try {
          Directory('$e\\ShaderFixes').listSync().forEach((element) {
            if (element is File) {
              shaderFilenames.add(element);
            }
          });
        } catch (e) {
          logger.i(e);
        }

        final shaderFixDir =
            '${context.read<AppState>().targetDir}\\ShaderFixes';

        if (isDisabled) {
          renameTarget = '${e.parent.path}\\$folderName';
          if (Directory(renameTarget).existsSync()) {
            showDirectoryExists(context, renameTarget);
            return;
          }
          try {
            if (shaderFilenames.isNotEmpty) {
              copyShaders(shaderFixDir, shaderFilenames);
            }
          } on FileSystemException catch (e) {
            logger.w(e);
            showUnableCopy(context, e.path!);
            return;
          }
        } else {
          renameTarget = '${e.parent.path}\\DISABLED $folderName';
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
        }

        e.renameSync(renameTarget);
      },
      child: Card(
        backgroundColor: color,
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    folderName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FluentTheme.of(context).typography.bodyStrong,
                  ),
                ),
                const SizedBox(width: 4),
                Button(
                  child: const Icon(FluentIcons.folder_open),
                  onPressed: () => openFolder(e),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildDesc(folderName, context),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Divider(direction: Axis.vertical),
                  ),
                  buildIni(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showUnableDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Error'),
        content: const Text('Failed to delete files in ShaderFixes'),
        actions: [
          FilledButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void showUnableCopy(BuildContext context, String filename) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Error'),
        content: Text('$filename already exists!'),
        actions: [
          FilledButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void copyShaders(String targetDir, List<File> shaderFilenames) {
    // check for existence first
    Directory(targetDir).listSync().forEach((e) {
      for (var e2 in shaderFilenames) {
        final last2 = e.path.split('\\').last;
        if (last2 == e2.path.split('\\').last) {
          throw FileSystemException(
            'Target directory is not empty',
            last2,
          );
        }
      }
    });
    for (final element in shaderFilenames) {
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

  Widget buildDesc(String folderName, BuildContext context) {
    return () {
      late final FileSystemEntity preview;
      try {
        var listSync = e.listSync();
        preview = listSync.firstWhere((element) {
          final lowerCase = element.path.split('\\').last.toLowerCase();
          return lowerCase == 'preview.png' ||
              lowerCase == 'preview.jpg' ||
              lowerCase == 'preview.jpeg';
        });
      } on StateError {
        return const Expanded(child: Center(child: Icon(FluentIcons.unknown)));
      } on PathNotFoundException {
        return const Expanded(child: Center(child: Icon(FluentIcons.error)));
      }
      final File previewFile;
      try {
        previewFile = preview as File;
      } on TypeError {
        return const Expanded(
          child: Center(
            child: Text("Invalid preview file entry"),
          ),
        );
      }
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250),
        child: Image.file(
          previewFile,
          filterQuality: FilterQuality.medium,
        ),
      );
    }();
  }

  Widget buildIni() {
    return IniList(e);
  }

  void showDirectoryExists(BuildContext context, String renameTarget) {
    renameTarget = renameTarget.split('\\').last;
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Error'),
        content: Text('$renameTarget already exists!'),
        actions: [
          FilledButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class IniList extends StatefulWidget {
  final Directory folder;

  const IniList(
    this.folder, {
    super.key,
  });

  @override
  State<IniList> createState() => _IniListState();
}

class _IniListState extends State<IniList> {
  late StreamSubscription<FileSystemEvent> watcher;

  @override
  void initState() {
    super.initState();
    watcher = widget.folder.watch().listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    watcher.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alliniFile = allFilesToWidget(getActiveiniFiles(widget.folder));
    return Flexible(
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
}

List<Widget> allFilesToWidget(List<File> allFiles) {
  List<Widget> alliniFile = [];
  for (var i = 0; i < allFiles.length; i++) {
    final folderName = p.basename(allFiles[i].path);
    alliniFile.add(Row(
      children: [
        Expanded(
          child: Tooltip(
            message: folderName,
            child: Text(
              folderName,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Button(
          child: const Icon(FluentIcons.document_management),
          onPressed: () => runProgram(allFiles[i]),
        ),
      ],
    ));
    late String lastSection;
    bool metSection = false;
    allFiles[i].readAsLinesSync().forEach((e) {
      if (e.startsWith('[')) {
        metSection = false;
      }
      final regExp = RegExp(r'\[Key.*?\]');
      final match = regExp.firstMatch(e)?.group(0)!;
      if (match != null) {
        alliniFile.add(Text(match));
        lastSection = match;
        metSection = true;
      }
      if (e.toLowerCase().startsWith('key')) {
        alliniFile.add(Row(
          children: [
            const Text(
              'key:',
            ),
            Expanded(
              child: EditorText(
                section: lastSection,
                line: e,
                file: allFiles[i],
              ),
            )
          ],
        ));
      } else if (e.toLowerCase().startsWith('back')) {
        alliniFile.add(Row(
          children: [
            const Text(
              'back:',
            ),
            Expanded(
              child: EditorText(
                section: lastSection,
                line: e,
                file: allFiles[i],
              ),
            )
          ],
        ));
      } else if (e.startsWith('\$') && metSection) {
        final cycles = ','.allMatches(e.split(';').first).length + 1;
        alliniFile.add(Text('Cycles: $cycles'));
      }
    });
  }
  return alliniFile;
}

class EditorText extends StatelessWidget {
  final focusNode = FocusNode();
  final String section;
  final String line;
  final File file;

  EditorText({
    super.key,
    required this.section,
    required this.line,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    final String text = line.split('=').last.trim();
    final textEditingController = TextEditingController(text: text);
    return Focus(
      focusNode: focusNode,
      onFocusChange: (event) {
        if (event) return;
        textEditingController.text = text;
        focusNode.unfocus();
      },
      child: TextBox(
        controller: textEditingController,
        onSubmitted: (value) {
          bool metSection = false;
          List<String> allLines = [];
          final lineHeader = line.split('=').first.trim();
          file.readAsLinesSync().forEach((element) {
            final regExp = RegExp(r'\[Key.*?\]').firstMatch(element);
            if (regExp != null && regExp.group(0) == section) {
              metSection = true;
            }
            if (metSection && element.toLowerCase() == line.toLowerCase()) {
              final first = '$lineHeader ';
              allLines.add('$first= ${value.trim()}');
            } else {
              allLines.add(element);
            }
          });
          file.writeAsStringSync(allLines.join('\n'));
        },
      ),
    );
  }
}
