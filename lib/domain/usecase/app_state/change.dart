import 'package:genshin_mod_manager/domain/entity/app_state.dart';

AppState callChangeModRootUseCase(final AppState curState, final String path) =>
    curState.copyWith(modRoot: path);

AppState callChangeModExecFileUseCase(
  final AppState curState,
  final String path,
) =>
    curState.copyWith(modExecFile: path);

AppState callChangeLauncherFileUseCase(
  final AppState curState,
  final String path,
) =>
    curState.copyWith(launcherFile: path);

AppState callChangeRunTogetherUseCase(
  final AppState curState,
  final bool value,
) =>
    curState.copyWith(runTogether: value);

AppState callChangeMoveOnDragUseCase(
  final AppState curState,
  final bool value,
) =>
    curState.copyWith(moveOnDrag: value);

AppState callChangeShowFolderIconUseCase(
  final AppState curState,
  final bool value,
) =>
    curState.copyWith(showFolderIcon: value);

AppState callChangeShowEnabledModsFirstUseCase(
  final AppState curState,
  final bool value,
) =>
    curState.copyWith(showEnabledModsFirst: value);

AppState callChangePresetDataUseCase(
  final AppState curState,
  final Map<String, Map<String, List<String>>> data,
) =>
    curState.copyWith(presetData: data);
