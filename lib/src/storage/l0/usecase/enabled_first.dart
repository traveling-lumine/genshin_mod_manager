import '../api/persistent_storage.dart';
import '../constants.dart';

final showEnabledModsFirstKey = StorageAccessKey.showEnabledModsFirst.name;
const showEnabledModsFirstDefault = false;

bool initializeEnabledFirstUseCase(final PersistentStorage? watch) {
  final showEnabledModsFirst =
      watch?.getBool(showEnabledModsFirstKey) ?? showEnabledModsFirstDefault;
  return showEnabledModsFirst;
}

void setEnabledFirstUseCase(final PersistentStorage? read, final bool value) =>
    read?.setBool(showEnabledModsFirstKey, value);
