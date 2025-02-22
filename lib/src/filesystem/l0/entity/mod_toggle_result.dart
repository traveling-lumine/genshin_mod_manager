import 'package:freezed_annotation/freezed_annotation.dart';

part 'mod_toggle_result.freezed.dart';

@freezed
sealed class ModToggleResult with _$ModToggleResult {
  const factory ModToggleResult.modNotFound() = ModToggleResultModNotFound;
  const factory ModToggleResult.alreadyEnabled() =
      ModToggleResultAlreadyEnabled;
  const factory ModToggleResult.alreadyDisabled() =
      ModToggleResultAlreadyDisabled;
  const factory ModToggleResult.modRenameClash(final String name) =
      ModToggleResultModRenameClash;
  const factory ModToggleResult.modRenameFailed() =
      ModToggleResultModRenameFailed;

  const factory ModToggleResult.modHasNoShaders() =
      ModToggleResultModHasNoShaders;
  const factory ModToggleResult.shaderExists() = ModToggleResultShaderExists;
  const factory ModToggleResult.shaderCopyFailed() =
      ModToggleResultShaderCopyFailed;

  const factory ModToggleResult.shaderDeleteFailed() =
      ModToggleResultShaderDeleteFailed;

  const factory ModToggleResult.shaderCleanupFailed() =
      ModToggleResultShaderCleanupFailed;

  const factory ModToggleResult.done() = ModToggleResultDone;
}
