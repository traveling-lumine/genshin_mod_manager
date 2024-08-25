import '../persistent_storage.dart';

const darkModeKey = 'darkMode';
const darkModeDefault = true;

bool initializeDarkModeUseCase(final PersistentStorage watch) =>
    watch.getBool(darkModeKey) ?? darkModeDefault;

void setDarkModeUseCase(final PersistentStorage read, final bool value) {
  read.setBool(darkModeKey, value);
}
