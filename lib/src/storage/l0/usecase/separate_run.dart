import '../api/persistent_storage.dart';
import '../constants.dart';

String getKey(final String currentGame) =>
    '$currentGame${StorageAccessKey.separateRunSuffix.name}';

bool? initializeSeparateRunOverrideUseCase(
  final PersistentStorage? repository,
  final String currentGame,
) =>
    repository?.getBool(getKey(currentGame));

void setSeparateRunOverrideUseCase(
  final PersistentStorage? repository,
  final String currentGame,
  final bool? value,
) {
  if (value == null) {
    repository?.removeKey(getKey(currentGame));
    return;
  }
  repository?.setBool(getKey(currentGame), value);
}
