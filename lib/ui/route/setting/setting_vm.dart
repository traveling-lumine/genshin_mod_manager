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

  void onModRootSelect(String path);

  void onModExecSelect(String path);

  void onLauncherSelect(String path);

  void onRunTogetherChanged(bool value);

  void onMoveOnDragChanged(bool value);

  void onShowFolderIconChanged(bool value);

  void onShowEnabledModsFirstChanged(bool value);
}

SettingViewModel createSettingViewModel({
  required AppStateService appStateService,
}) {
  return _SettingViewModelImpl(appStateService: appStateService);
}

class _SettingViewModelImpl extends ChangeNotifier implements SettingViewModel {
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

  _SettingViewModelImpl({
    required this.appStateService,
  })  : modRoot = appStateService.modRoot.latest,
        modExecFile = appStateService.modExecFile.latest,
        launcherFile = appStateService.launcherFile.latest,
        moveOnDrag = appStateService.moveOnDrag.latest,
        runTogether = appStateService.runTogether.latest,
        showFolderIcon = appStateService.showFolderIcon.latest,
        showEnabledModsFirst = appStateService.showEnabledModsFirst.latest {
    _modRootSubscription = appStateService.modRoot.stream.listen((event) {
      modRoot = event;
      notifyListeners();
    });
    _modExecFileSubscription =
        appStateService.modExecFile.stream.listen((event) {
      modExecFile = event;
      notifyListeners();
    });
    _launcherFileSubscription =
        appStateService.launcherFile.stream.listen((event) {
      launcherFile = event;
      notifyListeners();
    });
    _moveOnDragSubscription = appStateService.moveOnDrag.stream.listen((event) {
      moveOnDrag = event;
      notifyListeners();
    });
    _runTogetherSubscription =
        appStateService.runTogether.stream.listen((event) {
      runTogether = event;
      notifyListeners();
    });
    _showFolderIconSubscription =
        appStateService.showFolderIcon.stream.listen((event) {
      showFolderIcon = event;
      notifyListeners();
    });
    _showEnabledModsFirstSubscription =
        appStateService.showEnabledModsFirst.stream.listen((event) {
      showEnabledModsFirst = event;
      notifyListeners();
    });
  }

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
  void onModRootSelect(String path) {
    appStateService.setModRoot(path);
  }

  @override
  void onModExecSelect(path) {
    appStateService.setModExecFile(path);
  }

  @override
  void onLauncherSelect(path) {
    appStateService.setLauncherFile(path);
  }

  @override
  void onRunTogetherChanged(bool value) {
    appStateService.setRunTogether(value);
  }

  @override
  void onMoveOnDragChanged(bool value) {
    appStateService.setMoveOnDrag(value);
  }

  @override
  void onShowFolderIconChanged(bool value) {
    appStateService.setShowFolderIcon(value);
  }

  @override
  void onShowEnabledModsFirstChanged(bool value) {
    appStateService.setShowEnabledModsFirst(value);
  }
}
