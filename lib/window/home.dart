import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/base/appbar.dart';
import 'package:genshin_mod_manager/extension/pathops.dart';
import 'package:genshin_mod_manager/io/fsops.dart';
import 'package:genshin_mod_manager/service/app_state_service.dart';
import 'package:genshin_mod_manager/service/folder_observer_service.dart';
import 'package:genshin_mod_manager/third_party/fluent_ui/auto_suggest_box.dart';
import 'package:genshin_mod_manager/widget/folder_drop_target.dart';
import 'package:genshin_mod_manager/window/page/category.dart';
import 'package:genshin_mod_manager/window/page/setting.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class HomeWindow extends StatefulWidget {
  const HomeWindow({super.key});

  @override
  State<HomeWindow> createState() => _HomeWindowState();
}

class _HomeWindowState<T extends StatefulWidget> extends State<HomeWindow> {
  static const _navigationPaneOpenWidth = 270.0;
  static final _logger = Logger();

  Key? selectedKey;
  int? selected;

  @override
  Widget build(BuildContext context) {
    final imageFiles =
        context.select<CategoryIconFolderObserverService, List<File>>(
            (value) => value.curFiles);
    final List<_FolderPaneItem> subFolders = context
        .select<DirWatchService, List<PathW>>((value) {
          return value.curDirs.map((e) => e.pathW).toList(growable: false);
        })
        .map((e) => _FolderPaneItem(
              dirPath: e,
              imageFile: findPreviewFileIn(imageFiles, name: e.basename),
            ))
        .toList(growable: false);

    final List<NavigationPaneItem> footerItems = [
      PaneItemSeparator(
        key: const ValueKey('<separator>'),
      ),
      ..._buildPaneItemActions(context),
      PaneItem(
        key: const ValueKey('<settings>'),
        icon: const Icon(FluentIcons.settings),
        title: const Text('Settings'),
        body: const SettingPage(),
      ),
    ];

    final List<NavigationPaneItem> combined = [
      ...subFolders,
      ...footerItems,
    ];

    // search matching key in combined list
    final idx = combined.indexWhere((e) => e.key == selectedKey);
    if (idx == -1) {
      if (subFolders.isEmpty) {
        selected = combined.length - 1;
        selectedKey = combined.last.key;
      } else {
        final selVal = selected;
        final afterVal =
            selVal == null ? 0 : selVal.clamp(0, subFolders.length - 1);
        selected = afterVal;
        selectedKey = subFolders[afterVal].key;
      }
    } else {
      selected = idx;
    }

    return NavigationView(
      transitionBuilder: (child, animation) =>
          SuppressPageTransition(child: child),
      appBar: getAppbar('Genshin Mod Manager'),
      pane: NavigationPane(
        selected: selected,
        onChanged: (value) => _setSelectedState(value, combined[value].key!),
        displayMode: PaneDisplayMode.auto,
        size: const NavigationPaneSize(
            openWidth: _HomeWindowState._navigationPaneOpenWidth),
        autoSuggestBox: _buildAutoSuggestBox(subFolders, combined),
        autoSuggestBoxReplacement: const Icon(FluentIcons.search),
        items: subFolders.map((e) {
          // haha... blame List<T>::+ operator
          // ignore: unnecessary_cast
          return e as NavigationPaneItem;
        }).toList(growable: false),
        footerItems: footerItems,
      ),
    );
  }

  List<PaneItemAction> _buildPaneItemActions(BuildContext context) {
    const icon = Icon(FluentIcons.user_window);
    return context.select<AppStateService, bool>((value) => value.runTogether)
        ? [
            PaneItemAction(
              key: const ValueKey('<run_both>'),
              icon: icon,
              title: const Text('Run 3d migoto & launcher'),
              onTap: () {
                _runMigoto(context);
                _runLauncher(context);
              },
            ),
          ]
        : [
            PaneItemAction(
              key: const ValueKey('<run_migoto>'),
              icon: icon,
              title: const Text('Run 3d migoto'),
              onTap: () => _runMigoto(context),
            ),
            PaneItemAction(
              key: const ValueKey('<run_launcher>'),
              icon: icon,
              title: const Text('Run launcher'),
              onTap: () => _runLauncher(context),
            ),
          ];
  }

  Widget _buildAutoSuggestBox(
      List<_FolderPaneItem> subFolders, List<NavigationPaneItem> combined) {
    return AutoSuggestBox2(
      items: subFolders
          .map((e) => AutoSuggestBoxItem2(
                value: e.key,
                label: e.dirPath.basename.asString,
              ))
          .toList(growable: false),
      trailingIcon: const Icon(FluentIcons.search),
      onSelected: (item) {
        final idx = subFolders.indexWhere((e) => e.key == item.value);
        _setSelectedState(idx, combined[idx].key!);
      },
      onSubmissionFailed: (text) {
        if (text.isEmpty) return;
        test(e) {
          final name =
              (e.key as ValueKey<PathW>).value.basename.asString.toLowerCase();
          return name.startsWith(text.toLowerCase());
        }

        final index = subFolders.indexWhere(test);
        if (index == -1) return;
        _setSelectedState(index, combined[index].key!);
      },
    );
  }

  void _runMigoto(BuildContext context) {
    final path = context.read<AppStateService>().modExecFile;
    runProgram(path.toFile);
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
            title: const Text('Ran 3d migoto'),
            action: IconButton(
              icon: const Icon(FluentIcons.clear),
              onPressed: close,
            ));
      },
    );
    _logger.t('Ran 3d migoto $path');
  }

  void _runLauncher(BuildContext context) {
    final launcher = context.read<AppStateService>().launcherFile;
    runProgram(launcher.toFile);
    _logger.t('Ran launcher $launcher');
  }

  void _setSelectedState(int index, Key key) {
    setState(() {
      selected = index;
      selectedKey = key;
    });
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Key>('selectedKey', selectedKey));
    properties.add(IntProperty('selected', selected));
  }
}

class _FolderPaneItem extends PaneItem {
  static const maxIconWidth = 80.0;

  static Widget _getIcon(File? imageFile) {
    return Selector<AppStateService, bool>(
      selector: (_, service) => service.showFolderIcon,
      builder: (_, value, __) =>
          value ? _buildImage(imageFile) : const Icon(FluentIcons.folder_open),
    );
  }

  static Widget _buildImage(File? imageFile) {
    final Image image;
    if (imageFile == null) {
      image = Image.asset('images/app_icon.ico');
    } else {
      image = Image.file(
        imageFile,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      );
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: maxIconWidth),
      child: AspectRatio(
        aspectRatio: 1,
        child: image,
      ),
    );
  }

  PathW dirPath;

  _FolderPaneItem({
    required this.dirPath,
    File? imageFile,
  }) : super(
          title: Text(
            dirPath.basename.asString,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: _getIcon(imageFile),
          body: DirWatchProvider(
            dir: dirPath.toDirectory,
            child: CategoryPage(dirPath: dirPath),
          ),
          key: ValueKey(dirPath),
        );

  @override
  Widget build(BuildContext context, bool selected, VoidCallback? onPressed,
      {PaneDisplayMode? displayMode,
      bool showTextOnTop = true,
      int? itemIndex,
      bool? autofocus}) {
    return FolderDropTarget(
      dirPath: dirPath,
      child: super.build(
        context,
        selected,
        onPressed,
        displayMode: displayMode,
        showTextOnTop: showTextOnTop,
        itemIndex: itemIndex,
        autofocus: autofocus,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<PathW>('dirPath', dirPath));
  }
}
