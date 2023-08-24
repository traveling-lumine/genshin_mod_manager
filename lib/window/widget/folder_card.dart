import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/io/fsops.dart';
import 'package:genshin_mod_manager/provider/app_state.dart';
import 'package:genshin_mod_manager/window/page/folder.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

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
