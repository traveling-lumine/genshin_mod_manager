import 'package:genshin_mod_manager/domain/constant.dart';
import 'package:genshin_mod_manager/domain/repo/persistent_storage.dart';

bool initializeDarkModeUseCase(final PersistentStorage watch) =>
    watch.getBool(darkModeKey) ?? darkModeDefault;

void setDarkModeUseCase(final PersistentStorage read, final bool value) {
  read.setBool(darkModeKey, value);
}
