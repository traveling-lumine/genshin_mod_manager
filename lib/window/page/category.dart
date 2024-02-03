import 'dart:io';

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
          commandBar: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(icon: const Icon(FluentIcons.add), onPressed: () {}),
              const SizedBox(width: 8),
              ComboBox(
                items: [
                  ComboBoxItem(
                    child: GestureDetector(
                      onTapUp: (details) {
                        displayInfoBar(
                          context,
                          builder:
                              (BuildContext context, void Function() close) {
                            return InfoBar(
                              title: const Text('Enabled first'),
                              onClose: close,
                            );
                          },
                        );
                      },
                      onSecondaryTapUp: (details) {
                        displayInfoBar(
                          context,
                          builder:
                              (BuildContext context, void Function() close) {
                            return InfoBar(
                              title: const Text('Enabled R first'),
                              onClose: close,
                            );
                          },
                        );
                      },
                      child: const Text('Enabled first'),
                    ),
                  ),
                  const ComboBoxItem(child: Text('Disabled first')),
                ],
                placeholder: const Text('Preset...'),
                onChanged: (value) {},
              ),
              SizedBox(
                width: 60,
                child: CommandBar(
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
            builder: (context, enabledFirst, child) {
              return _FolderMatchWidget(enabledFirst: enabledFirst);
            },
          ),
        ),
      ),
    );
  }
}

class _FolderMatchWidget extends StatefulWidget {
  final bool enabledFirst;

  const _FolderMatchWidget({required this.enabledFirst});

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
          final a2 = a.basename.enabledForm.asString;
          final b2 = b.basename.enabledForm.asString;
          var compareTo = a2.toLowerCase().compareTo(b2.toLowerCase());
          if (widget.enabledFirst) {
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

    if (currentChildren == null) {
      currentChildren = dirs.map((e) => _buildCharaCard(e)).toList();
    } else {
      final List<CharaScope> newCurrentChildren = [];
      for (var i = 0; i < dirs.length; i++) {
        final dir = dirs[i];
        final idx = currentChildren!.indexWhere((e) {
          return e.dir.path == dir.path;
        });
        if (idx == -1) {
          newCurrentChildren.add(_buildCharaCard(dir));
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

  CharaScope _buildCharaCard(Directory dir) {
    return CharaScope(
      key: Key(dir.path),
      dir: dir,
    );
  }
}
