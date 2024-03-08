import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/data/extension/pathops.dart';
import 'package:genshin_mod_manager/data/io/fsops.dart';
import 'package:genshin_mod_manager/ui/route/category/mod_card.dart';
import 'package:genshin_mod_manager/ui/service/app_state_service.dart';
import 'package:genshin_mod_manager/ui/service/folder_observer_service.dart';
import 'package:genshin_mod_manager/ui/widget/category_drop_target.dart';
import 'package:genshin_mod_manager/ui/widget/preset_control.dart';
import 'package:genshin_mod_manager/ui/widget/thick_scrollbar.dart';
import 'package:genshin_mod_manager/ui/widget/third_party/flutter/min_extent_delegate.dart';
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
    return PageHeader(
      title: Text(category),
      commandBar: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          PresetControlWidget(isLocal: true, category: category),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: SizedBox(
              width: 56,
              child: RepaintBoundary(
                child: CommandBar(
                  overflowBehavior: CommandBarOverflowBehavior.clip,
                  primaryItems: [
                    CommandBarButton(
                      icon: const Icon(FluentIcons.folder_open),
                      onPressed: () {
                        final categoryDir = context
                            .read<AppStateService>()
                            .modRoot
                            .pJoin(category);
                        openFolder(categoryDir);
                      },
                    ),
                    CommandBarButton(
                      icon: const Icon(FluentIcons.download),
                      onPressed: () {
                        final escapedCategory = Uri.encodeComponent(category);
                        context.push('/nahidastore?category=$escapedCategory');
                      },
                    ),
                  ],
                ),
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
          return _CategoryGrid(key: Key(category), enabledFirst: enabledFirst);
        },
      ),
    );
  }
}

class _CategoryGrid extends StatefulWidget {
  final bool enabledFirst;

  const _CategoryGrid({super.key, required this.enabledFirst});

  @override
  State<_CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<_CategoryGrid> {
  static const minCrossAxisExtent = 440.0;
  static const mainAxisExtent = 400.0;

  List<ModCard>? currentChildren;

  @override
  Widget build(BuildContext context) {
    final dirs = context.watch<DirWatchService>().curEntities
      ..sort(
        (a, b) {
          final aBase = a.path.pBasename;
          final bBase = b.path.pBasename;
          if (widget.enabledFirst) {
            final aEnabled = aBase.pIsEnabled;
            final bEnabled = bBase.pIsEnabled;
            if (aEnabled && !bEnabled) {
              return -1;
            } else if (!aEnabled && bEnabled) {
              return 1;
            }
          }
          final aLower = aBase.pEnabledForm.toLowerCase();
          final bLower = bBase.pEnabledForm.toLowerCase();
          final compareTo = aLower.compareTo(bLower);
          return compareTo;
        },
      );

    if (currentChildren == null) {
      currentChildren = dirs.map((e) => _buildCharaCard(e.path)).toList();
    } else {
      final List<ModCard> newCurrentChildren = [];
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

  ModCard _buildCharaCard(String path) {
    return ModCard(
      key: Key(path),
      path: path,
    );
  }
}
