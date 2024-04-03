import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genshin_mod_manager/domain/entity/preset.dart';

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
    final PresetData? presetData,
  }) = _AppState;
}
