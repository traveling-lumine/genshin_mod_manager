import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_state.freezed.dart';

@freezed
class AppState with _$AppState {
  const factory AppState({
    required final bool runTogether,
    required final bool moveOnDrag,
    required final bool showFolderIcon,
    required final bool showEnabledModsFirst,
    final String? modRoot,
    final String? modExecFile,
    final String? launcherFile,
    final Map<String, Map<String, List<String>>>? presetData,
  }) = _AppState;
}
