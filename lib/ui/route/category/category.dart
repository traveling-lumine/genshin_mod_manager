import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genshin_mod_manager/data/helper/fsops.dart';
import 'package:genshin_mod_manager/data/helper/mod_switcher.dart';
import 'package:genshin_mod_manager/data/helper/path_op_string.dart';
import 'package:genshin_mod_manager/data/repo/akasha.dart';
import 'package:genshin_mod_manager/data/repo/mod_writer.dart';
import 'package:genshin_mod_manager/domain/entity/ini.dart';
import 'package:genshin_mod_manager/domain/entity/mod.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/ui/constant.dart';
import 'package:genshin_mod_manager/ui/provider/app_state.dart';
import 'package:genshin_mod_manager/ui/provider/category.dart';
import 'package:genshin_mod_manager/ui/provider/ini_widget_vm.dart';
import 'package:genshin_mod_manager/ui/provider/mod_card_vm.dart';
import 'package:genshin_mod_manager/ui/util/display_infobar.dart';
import 'package:genshin_mod_manager/ui/widget/category_drop_target.dart';
import 'package:genshin_mod_manager/ui/widget/intrinsic_command_bar.dart';
import 'package:genshin_mod_manager/ui/widget/preset_control.dart';
import 'package:genshin_mod_manager/ui/widget/thick_scrollbar.dart';
import 'package:genshin_mod_manager/ui/widget/third_party/flutter/min_extent_delegate.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:window_manager/window_manager.dart';

part 'ini_widget.dart';
part 'mod_card.dart';

class CategoryRoute extends StatelessWidget {
  const CategoryRoute({required this.category, super.key});

  static const _minCrossAxisExtent = 440.0;
  static const _mainAxisExtent = 400.0;
  final ModCategory category;

  @override
  Widget build(final BuildContext context) => CategoryDropTarget(
        category: category,
        child: ScaffoldPage(
          header: _buildHeader(context),
          content: _buildContent(),
        ),
      );

  Widget _buildHeader(final BuildContext context) => PageHeader(
        title: Text(category.name),
        commandBar: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PresetControlWidget(
              isLocal: true,
              category: category,
            ),
            const SizedBox(width: 16),
            IntrinsicCommandBarCard(
              child: CommandBar(
                overflowBehavior: CommandBarOverflowBehavior.clip,
                primaryItems: [
                  CommandBarButton(
                    icon: const Icon(FluentIcons.folder_open),
                    onPressed: () {
                      openFolder(category.path);
                    },
                  ),
                  CommandBarButton(
                    icon: const Icon(FluentIcons.download),
                    onPressed: () => unawaited(
                      context.push(kNahidaStoreRoute, extra: category),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildContent() => ThickScrollbar(
        child: Consumer(
          builder: (final context, final ref, final child) {
            final value = ref.watch(categoryWatcherProvider(category));
            return value.when(
              skipLoadingOnReload: true,
              data: (final data) {
                final children =
                    data.map((final e) => ModCard(mod: e)).toList();
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithMinCrossAxisExtent(
                    minCrossAxisExtent: _minCrossAxisExtent,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    mainAxisExtent: _mainAxisExtent,
                  ),
                  itemCount: children.length,
                  itemBuilder: (final context, final index) => children[index],
                );
              },
              error: (final error, final stackTrace) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.error),
                    Text('Error: $error\n$stackTrace'),
                  ],
                ),
              ),
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ProgressRing(),
                    SizedBox(height: 16),
                    Text('Loading...'),
                  ],
                ),
              ),
            );
          },
        ),
      );

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ModCategory>('category', category));
  }
}
