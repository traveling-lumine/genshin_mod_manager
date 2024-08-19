import 'package:genshin_mod_manager/domain/repo/persistent_storage.dart';

const showEnabledModsFirstKey = 'showEnabledModsFirst';
const showEnabledModsFirstDefault = false;

bool initializeEnabledFirstUseCase(final PersistentStorage watch) {
  final showEnabledModsFirst =
      watch.getBool(showEnabledModsFirstKey) ?? showEnabledModsFirstDefault;
  return showEnabledModsFirst;
}

void setEnabledFirstUseCase(final PersistentStorage read, final bool value) =>
    read.setBool(showEnabledModsFirstKey, value);
