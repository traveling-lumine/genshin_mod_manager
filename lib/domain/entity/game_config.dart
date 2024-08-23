import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'preset.dart';

part 'game_config.freezed.dart';

/// A configuration per game.
@freezed
class GameConfig with _$GameConfig {
  /// Creates a [GameConfig].
  const factory GameConfig({
    final String? modRoot,
    final String? modExecFile,
    final String? launcherFile,
    final PresetData? presetData,
  }) = _GameConfig;
}
