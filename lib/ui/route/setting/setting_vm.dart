import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/domain/repo/app_state.dart';
import 'package:genshin_mod_manager/ui/viewmodel_base.dart';

abstract interface class SettingViewModel implements BaseViewModel {
  String? get modRoot;

  String? get modExecFile;

  String? get launcherFile;

  bool? get runTogether;

  bool? get moveOnDrag;

  bool? get showFolderIcon;

  bool? get showEnabledModsFirst;

  void onModRootSelect(final String path);

  void onModExecSelect(final String path);

  void onLauncherSelect(final String path);

  void onRunTogetherChanged(final bool value);

  void onMoveOnDragChanged(final bool value);

  void onShowFolderIconChanged(final bool value);

  void onShowEnabledModsFirstChanged(final bool value);
}

SettingViewModel createSettingViewModel({
  required final AppStateService appStateService,
}) =>
    _SettingViewModelImpl(appStateService: appStateService);

class _SettingViewModelImpl extends ChangeNotifier implements SettingViewModel {
  _SettingViewModelImpl({
    required this.appStateService,
  })  : modRoot = appStateService.modRoot.latest,
        modExecFile = appStateService.modExecFile.latest,
        launcherFile = appStateService.launcherFile.latest,
        moveOnDrag = appStateService.moveOnDrag.latest,
        runTogether = appStateService.runTogether.latest,
        showFolderIcon = appStateService.showFolderIcon.latest,
        showEnabledModsFirst = appStateService.showEnabledModsFirst.latest {
    _modRootSubscription = appStateService.modRoot.stream.listen((final event) {
      modRoot = event;
      notifyListeners();
    });
    _modExecFileSubscription =
        appStateService.modExecFile.stream.listen((final event) {
      modExecFile = event;
      notifyListeners();
    });
    _launcherFileSubscription =
        appStateService.launcherFile.stream.listen((final event) {
      launcherFile = event;
      notifyListeners();
    });
    _moveOnDragSubscription =
        appStateService.moveOnDrag.stream.listen((final event) {
      moveOnDrag = event;
      notifyListeners();
    });
    _runTogetherSubscription =
        appStateService.runTogether.stream.listen((final event) {
      runTogether = event;
      notifyListeners();
    });
    _showFolderIconSubscription =
        appStateService.showFolderIcon.stream.listen((final event) {
      showFolderIcon = event;
      notifyListeners();
    });
    _showEnabledModsFirstSubscription =
        appStateService.showEnabledModsFirst.stream.listen((final event) {
      showEnabledModsFirst = event;
      notifyListeners();
    });
  }

  late final StreamSubscription<String> _modRootSubscription;
  late final StreamSubscription<String> _modExecFileSubscription;
  late final StreamSubscription<String> _launcherFileSubscription;
  late final StreamSubscription<bool> _moveOnDragSubscription;
  late final StreamSubscription<bool> _runTogetherSubscription;
  late final StreamSubscription<bool> _showFolderIconSubscription;
  late final StreamSubscription<bool> _showEnabledModsFirstSubscription;

  final AppStateService appStateService;

  @override
  String? modRoot;

  @override
  String? modExecFile;

  @override
  String? launcherFile;

  @override
  bool? moveOnDrag;

  @override
  bool? runTogether;

  @override
  bool? showEnabledModsFirst;

  @override
  bool? showFolderIcon;

  @override
  void dispose() {
    _showEnabledModsFirstSubscription.cancel();
    _showFolderIconSubscription.cancel();
    _runTogetherSubscription.cancel();
    _moveOnDragSubscription.cancel();
    _launcherFileSubscription.cancel();
    _modExecFileSubscription.cancel();
    _modRootSubscription.cancel();
    super.dispose();
  }

  @override
  void onModRootSelect(final String path) {
    appStateService.setModRoot(path);
  }

  @override
  void onModExecSelect(final String path) {
    appStateService.setModExecFile(path);
  }

  @override
  void onLauncherSelect(final String path) {
    appStateService.setLauncherFile(path);
  }

  @override
  void onRunTogetherChanged(final bool value) {
    appStateService.setRunTogether(value);
  }

  @override
  void onMoveOnDragChanged(final bool value) {
    appStateService.setMoveOnDrag(value);
  }

  @override
  void onShowFolderIconChanged(final bool value) {
    appStateService.setShowFolderIcon(value);
  }

  @override
  void onShowEnabledModsFirstChanged(final bool value) {
    appStateService.setShowEnabledModsFirst(value);
  }
}
