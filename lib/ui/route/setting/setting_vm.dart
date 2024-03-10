import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:genshin_mod_manager/domain/repo/app_state_service.dart';
import 'package:genshin_mod_manager/ui/widget/third_party/flutter/no_deref_file_opener.dart';

abstract interface class SettingViewModel extends ChangeNotifier {
  get modRoot => null;

  get modExecFile => null;

  get launcherFile => null;

  get runTogether => null;

  get moveOnDrag => null;

  get showFolderIcon => null;

  get showEnabledModsFirst => null;

  void onModRootSelect();

  void onModExecSelect();

  void onLauncherSelect();

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
  final AppStateService _appStateService;

  @override
  get modRoot => _appStateService.modRoot;

  @override
  get modExecFile => _appStateService.modExecFile;

  @override
  get launcherFile => _appStateService.launcherFile;

  @override
  get moveOnDrag => _appStateService.moveOnDrag;

  @override
  get runTogether => _appStateService.runTogether;

  @override
  get showEnabledModsFirst => _appStateService.showEnabledModsFirst;

  @override
  get showFolderIcon => _appStateService.showFolderIcon;

  _SettingViewModelImpl({
    required AppStateService appStateService,
  }) : _appStateService = appStateService {
    _appStateService.addListener(appStateListener);
  }

  void appStateListener() {
    notifyListeners();
  }

  @override
  void dispose() {
    _appStateService.removeListener(appStateListener);
    super.dispose();
  }

  @override
  void onModRootSelect() {
    final dir = DirectoryPicker().getDirectory();
    if (dir == null) return;
    _appStateService.modRoot = dir.path;
  }

  @override
  void onModExecSelect() {
    final file = OpenNoDereferenceFilePicker().getFile();
    if (file == null) return;
    _appStateService.modExecFile = file.path;
  }

  @override
  void onLauncherSelect() {
    final file = OpenNoDereferenceFilePicker().getFile();
    if (file == null) return;
    _appStateService.launcherFile = file.path;
  }

  @override
  void onRunTogetherChanged(bool value) {
    _appStateService.runTogether = value;
  }

  @override
  void onMoveOnDragChanged(bool value) {
    _appStateService.moveOnDrag = value;
  }

  @override
  void onShowFolderIconChanged(bool value) {
    _appStateService.showFolderIcon = value;
  }

  @override
  void onShowEnabledModsFirstChanged(bool value) {
    _appStateService.showEnabledModsFirst = value;
  }
}
