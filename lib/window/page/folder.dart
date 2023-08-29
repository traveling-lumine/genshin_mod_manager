import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/base/directory_watch_widget.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/io/fsops.dart';
import 'package:genshin_mod_manager/third_party/min_extent_delegate.dart';
import 'package:genshin_mod_manager/widget/folder_card.dart';
import 'package:genshin_mod_manager/widget/folder_drop_target.dart';

class FolderPage extends DirectoryWatchWidget {
  FolderPage({
    required super.dirPath,
  }) : super(key: ValueKey(dirPath));

  @override
  DWState<FolderPage> createState() => _FolderPageState();
}

class _FolderPageState extends DWState<FolderPage> {
  late List<Directory> allChildrenFolder;

  @override
  Widget build(BuildContext context) {
    return FolderDropTarget(
      dirPath: widget.dirPath,
      child: ScaffoldPage(
        header: PageHeader(
          title: Text(widget.dir.basename.asString),
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
              .map((e) => FolderCard(dirPath: e.pathString))
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
          final aBasename = a.basename;
          final bBasename = b.basename;
          final aString = aBasename.asString;
          final bString = bBasename.asString;
          final aName = aBasename.startsWith('DISABLED ')
              ? aString.substring(9)
              : aString;
          final bName = bBasename.startsWith('DISABLED ')
              ? bString.substring(9)
              : bString;
          var compareTo = aName.toLowerCase().compareTo(bName.toLowerCase());
          print('a: $aName, b: $bName, compareTo: $compareTo');
          return compareTo;
        },
      );
  }
}
