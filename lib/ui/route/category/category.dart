import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/ui/route/category/category_vm.dart';
import 'package:genshin_mod_manager/ui/route/category/mod_card.dart';
import 'package:genshin_mod_manager/ui/widget/category_drop_target.dart';
import 'package:genshin_mod_manager/ui/widget/intrinsic_command_bar.dart';
import 'package:genshin_mod_manager/ui/widget/preset_control.dart';
import 'package:genshin_mod_manager/ui/widget/thick_scrollbar.dart';
import 'package:genshin_mod_manager/ui/widget/third_party/flutter/min_extent_delegate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CategoryRoute extends StatelessWidget {
  final String category;

  CategoryRoute({
    required this.category,
  }) : super(key: Key(category));

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => createCategoryRouteViewModel(
        appStateService: context.read(),
        rootObserverService: context.read(),
        category: category,
      ),
      child: _CategoryRoute(category: category),
    );
  }
}

class _CategoryRoute extends StatelessWidget {
  static const minCrossAxisExtent = 440.0;
  static const mainAxisExtent = 400.0;
  final String category;

  const _CategoryRoute({required this.category});

  @override
  Widget build(BuildContext context) {
    return CategoryDropTarget(
      category: category,
      child: ScaffoldPage(
        header: _buildHeader(context),
        content: _buildContent(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final viewModel = context.read<CategoryRouteViewModel>();
    return PageHeader(
      title: Text(category),
      commandBar: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          PresetControlWidget(isLocal: true, category: category),
          const SizedBox(width: 16),
          IntrinsicCommandBarCard(
            child: CommandBar(
              overflowBehavior: CommandBarOverflowBehavior.clip,
              primaryItems: [
                CommandBarButton(
                  icon: const Icon(FluentIcons.folder_open),
                  onPressed: viewModel.onFolderOpen,
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
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ThickScrollbar(
      child: Selector<CategoryRouteViewModel, List<Mod>>(
        selector: (p0, p1) => p1.modPaths,
        builder: (context, value, child) {
          final children =
              value.map((e) => ModCard(path: e.path)).toList(growable: false);
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithMinCrossAxisExtent(
              minCrossAxisExtent: minCrossAxisExtent,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              mainAxisExtent: mainAxisExtent,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          );
        },
      ),
    );
  }
}
