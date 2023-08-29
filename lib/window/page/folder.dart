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
  static const minCrossAxisExtent = 400.0;
  static const mainAxisExtent = 380.0;

  late List<Directory> allChildrenFolder;

  @override
  Widget build(BuildContext context) {
    return FolderDropTarget(
      dirPath: widget.dirPath,
      child: ScaffoldPage(
        header: PageHeader(
          title: Text(widget.dirPath.basename.asString),
          commandBar: CommandBar(
            mainAxisAlignment: MainAxisAlignment.end,
            primaryItems: [
              CommandBarButton(
                icon: const Icon(FluentIcons.folder_open),
                onPressed: () {
                  openFolder(widget.dirPath.toDirectory);
                },
              ),
            ],
          ),
        ),
        content: GridView(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithMinCrossAxisExtent(
            minCrossAxisExtent: minCrossAxisExtent,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: mainAxisExtent,
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
    allChildrenFolder = getFoldersUnder(widget.dirPath.toDirectory)
      ..sort(
        (a, b) {
          final a2 = a.basename.enabledForm.asString;
          final b2 = b.basename.enabledForm.asString;
          var compareTo = a2.toLowerCase().compareTo(b2.toLowerCase());
          return compareTo;
        },
      );
  }
}
