import '../constants.dart';
import '../api/persistent_storage.dart';

final darkModeKey = StorageAccessKey.darkMode.name;
const darkModeDefault = true;

bool initializeDarkModeUseCase(final PersistentStorage? watch) =>
    watch?.getBool(darkModeKey) ?? darkModeDefault;

void setDarkModeUseCase(final PersistentStorage? read, final bool value) {
  read?.setBool(darkModeKey, value);
}
