import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/base/directory_watch_widget.dart';
import 'package:genshin_mod_manager/io/fsops.dart';
import 'package:genshin_mod_manager/provider/app_state.dart';
import 'package:genshin_mod_manager/third_party/min_extent_delegate.dart';
import 'package:genshin_mod_manager/window/widget/folder_card.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

class FolderPage extends DirectoryWatchWidget {
  const FolderPage({
    super.key,
    required super.dirPath,
  });

  @override
  DWState<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends DWState<FolderPage> {
  static final Logger logger = Logger();
  late List<Directory> allChildrenFolder;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (details) {
        final moveInsteadOfCopy = context.read<AppState>().moveOnDrag;
        for (final xFile in details.files) {
          final path = xFile.path;
          if (!FileSystemEntity.isDirectorySync(path)) continue;
          logger.d('Dragged $path');
          final dir = Directory(path);
          final newPath = p.join(widget.dirPath, p.basename(path));
          if (moveInsteadOfCopy) {
            try {
              dir.renameSync(newPath);
              logger.d('Moved $path to $newPath');
            } on PathExistsException {
              displayInfoBar(
                context,
                builder: (context, close) {
                  return InfoBar(
                    title: const Text('Folder already exists'),
                    severity: InfoBarSeverity.warning,
                    onClose: close,
                  );
                },
              );
            }
          } else {
            try {
              copyDirectorySync(dir, newPath);
              logger.d('Copied $path to $newPath');
            } on PathExistsException {
              displayInfoBar(
                context,
                builder: (context, close) {
                  return InfoBar(
                    title: const Text('Folder already exists'),
                    severity: InfoBarSeverity.warning,
                    onClose: close,
                  );
                },
              );
            }
          }
        }
      },
      child: ScaffoldPage(
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
            minCrossAxisExtent: 420,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 350,
          ),
          children: allChildrenFolder
              .map((e) => FolderCard(dirPath: e.path))
              .toList(),
        ),
      ),
    );
  }

  @override
  bool shouldUpdate(FileSystemEvent event) =>
      !(event is FileSystemModifyEvent && event.contentChanged);

  @override
  void updateFolder() {
    allChildrenFolder = getAllChildrenFolder(widget.dir)
      ..sort(
        (a, b) {
          var aName = p.basename(a.path);
          var bName = p.basename(b.path);
          aName = aName.startsWith('DISABLED ') ? aName.substring(9) : aName;
          bName = bName.startsWith('DISABLED ') ? bName.substring(9) : bName;
          return aName.toLowerCase().compareTo(bName.toLowerCase());
        },
      );
  }
}
