import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_state.freezed.dart';

@freezed
class AppState with _$AppState {
  const factory AppState({
    required final String modRoot,
    required final String modExecFile,
    required final String launcherFile,
    required final String presetData,
    required final bool runTogether,
    required final bool moveOnDrag,
    required final bool showFolderIcon,
    required final bool showEnabledModsFirst,
  }) = _AppState;
}
