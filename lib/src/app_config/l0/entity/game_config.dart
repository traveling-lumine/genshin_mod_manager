import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'preset.dart';

part 'game_config.freezed.dart';
part 'game_config.g.dart';

@freezed
class GameConfig with _$GameConfig {
  // annotation is valid.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory GameConfig({
    final String? modRoot,
    final String? modExecFile,
    final String? launcherFile,
    @Default(PresetData(global: {}, local: {})) final PresetData presetData,
    final bool? separateRunOverride,
  }) = _GameConfig;

  factory GameConfig.fromJson(final Map<String, dynamic> json) =>
      _$GameConfigFromJson(json);
}

@freezed
class GameConfigMediator with _$GameConfigMediator {
  // annotation is valid.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory GameConfigMediator({
    required final Map<String, GameConfig> gameConfig,
    final String? current,
  }) = _GameConfigMediator;

  factory GameConfigMediator.fromJson(final Map<String, dynamic> json) =>
      _$GameConfigMediatorFromJson(json);

  const GameConfigMediator._();

  GameConfig get currentGameConfig => gameConfig[current] ?? const GameConfig();
}
