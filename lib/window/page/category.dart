import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/io/fsops.dart';
import 'package:genshin_mod_manager/service/app_state_service.dart';
import 'package:genshin_mod_manager/service/folder_observer_service.dart';
import 'package:genshin_mod_manager/third_party/min_extent_delegate.dart';
import 'package:genshin_mod_manager/widget/chara_mod_card.dart';
import 'package:genshin_mod_manager/widget/folder_drop_target.dart';
import 'package:provider/provider.dart';

class CategoryPage extends StatelessWidget {
  static const minCrossAxisExtent = 400.0;
  static const mainAxisExtent = 380.0;

  final PathW dirPath;

  const CategoryPage({
    super.key,
    required this.dirPath,
  });

  @override
  Widget build(BuildContext context) {
    return FolderDropTarget(
      dirPath: dirPath,
      child: ScaffoldPage(
        header: PageHeader(
          title: Text(dirPath.basename.asString),
          commandBar: CommandBar(
            mainAxisAlignment: MainAxisAlignment.end,
            primaryItems: [
              CommandBarButton(
                icon: const Icon(FluentIcons.folder_open),
                onPressed: () {
                  openFolder(dirPath.toDirectory);
                },
              ),
            ],
          ),
        ),
        content: FluentTheme(
          data: FluentThemeData(
            scrollbarTheme: ScrollbarThemeData(
              thickness: 8,
              hoveringThickness: 10,
              scrollbarColor: Colors.grey[140],
            ),
          ),
          child: Selector<AppStateService, bool>(
            selector: (p0, p1) => p1.showEnabledModsFirst,
            builder: (context, selVal, child) {
              return Consumer<DirectFolderObserverService>(
                builder: (context, dirVal, child) {
                  final allChildrenFolder = dirVal.curDirs
                    ..sort(
                      (a, b) {
                        final a2 = a.basename.enabledForm.asString;
                        final b2 = b.basename.enabledForm.asString;
                        var compareTo =
                            a2.toLowerCase().compareTo(b2.toLowerCase());
                        if (selVal) {
                          final aEnabled = a.basename.isEnabled;
                          final bEnabled = b.basename.isEnabled;
                          if (aEnabled && !bEnabled) {
                            return -1;
                          } else if (!aEnabled && bEnabled) {
                            return 1;
                          }
                        }
                        return compareTo;
                      },
                    );
                  return GridView(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithMinCrossAxisExtent(
                      minCrossAxisExtent: minCrossAxisExtent,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      mainAxisExtent: mainAxisExtent,
                    ),
                    children: allChildrenFolder
                        .map((e) => DirectFileService(
                              dir: e,
                              child: CharaModCard(dirPath: e.pathW),
                            ))
                        .toList(),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
