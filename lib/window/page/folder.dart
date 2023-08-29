import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/widget/folder_drop_target.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;

import '../../base/directory_watch_widget.dart';
import '../../io/fsops.dart';
import '../../third_party/min_extent_delegate.dart';
import '../../widget/folder_card.dart';

class FolderPage extends DirectoryWatchWidget {
  FolderPage({
    required super.dirPath,
  }) : super(key: ValueKey(dirPath));

  @override
  DWState<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends DWState<FolderPage> {
  static final Logger logger = Logger();
  late List<Directory> allChildrenFolder;

  @override
  Widget build(BuildContext context) {
    return FolderDropTarget(
      dirPath: widget.dirPath,
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
    allChildrenFolder = getFoldersUnder(widget.dir)
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
