import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/io/fsops.dart';
import 'package:genshin_mod_manager/service/app_state_service.dart';
import 'package:genshin_mod_manager/service/folder_observer_service.dart';
import 'package:genshin_mod_manager/third_party/min_extent_delegate.dart';
import 'package:genshin_mod_manager/widget/category_drop_target.dart';
import 'package:genshin_mod_manager/widget/chara_mod_card.dart';
import 'package:genshin_mod_manager/widget/preset_control.dart';
import 'package:genshin_mod_manager/widget/thick_scrollbar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CategoryRoute extends StatelessWidget {
  final String category;

  const CategoryRoute({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final modRootPath = context.read<AppStateService>().modRoot;
    final categoryPath = modRootPath.pJoin(category);
    return ChangeNotifierProxyProvider<RecursiveObserverService,
        DirWatchService>(
      key: Key(category),
      create: (context) => DirWatchService(targetPath: categoryPath),
      update: (context, value, previous) => previous!..update(value.lastEvent),
      child: CategoryDropTarget(
        category: category,
        child: ScaffoldPage(
          header: _buildHeader(context),
          content: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final categoryDir = context.read<AppStateService>().modRoot.pJoin(category);
    return PageHeader(
      title: Text(category),
      commandBar: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          PresetControlWidget(isLocal: true, category: category),
          SizedBox(
            width: 110,
            child: RepaintBoundary(
              child: CommandBar(
                mainAxisAlignment: MainAxisAlignment.end,
                primaryItems: [
                  CommandBarButton(
                    icon: const Icon(FluentIcons.folder_open),
                    onPressed: () {
                      openFolder(categoryDir);
                    },
                  ),
                  CommandBarButton(
                    icon: const Icon(FluentIcons.download),
                    onPressed: () {
                      context.go('/nahidastore');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ThickScrollbar(
      child: Selector<AppStateService, bool>(
        selector: (p0, p1) => p1.showEnabledModsFirst,
        builder: (context, enabledFirst, child) {
          return _FolderMatchWidget(
              key: Key(category), enabledFirst: enabledFirst);
        },
      ),
    );
  }
}

class _FolderMatchWidget extends StatefulWidget {
  final bool enabledFirst;

  const _FolderMatchWidget({super.key, required this.enabledFirst});

  @override
  State<_FolderMatchWidget> createState() => _FolderMatchWidgetState();
}

class _FolderMatchWidgetState extends State<_FolderMatchWidget> {
  static const minCrossAxisExtent = 440.0;
  static const mainAxisExtent = 400.0;

  List<CharaScope>? currentChildren;

  @override
  Widget build(BuildContext context) {
    final dirs = context.watch<DirWatchService>().curDirs
      ..sort(
        (a, b) {
          final a2 = a.path.pBasename.pEnabledForm;
          final b2 = b.path.pBasename.pEnabledForm;
          var compareTo = a2.toLowerCase().compareTo(b2.toLowerCase());
          if (widget.enabledFirst) {
            final aEnabled = a.path.pBasename.pIsEnabled;
            final bEnabled = b.path.pBasename.pIsEnabled;
            if (aEnabled && !bEnabled) {
              return -1;
            } else if (!aEnabled && bEnabled) {
              return 1;
            }
          }
          return compareTo;
        },
      );

    if (currentChildren == null) {
      currentChildren = dirs.map((e) => _buildCharaCard(e.path)).toList();
    } else {
      final List<CharaScope> newCurrentChildren = [];
      for (var i = 0; i < dirs.length; i++) {
        final dir = dirs[i];
        final idx = currentChildren!.indexWhere((e) {
          return e.path == dir.path;
        });
        if (idx == -1) {
          newCurrentChildren.add(_buildCharaCard(dir.path));
        } else {
          newCurrentChildren.add(currentChildren![idx]);
        }
      }
      currentChildren = newCurrentChildren;
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithMinCrossAxisExtent(
        minCrossAxisExtent: minCrossAxisExtent,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: mainAxisExtent,
      ),
      itemCount: currentChildren!.length,
      itemBuilder: (BuildContext context, int index) => currentChildren![index],
    );
  }

  CharaScope _buildCharaCard(String path) {
    return CharaScope(
      key: Key(path),
      path: path,
    );
  }
}
