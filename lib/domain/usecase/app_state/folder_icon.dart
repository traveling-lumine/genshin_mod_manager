import 'package:genshin_mod_manager/domain/constant.dart';
import 'package:genshin_mod_manager/domain/repo/persistent_storage.dart';

bool initializeFolderIconUseCase(final PersistentStorage watch) =>
    watch.getBool(showFolderIconKey) ?? showFolderIconDefault;
void setFolderIconUseCase(final PersistentStorage read, final bool value) =>
    read.setBool(showFolderIconKey, value);
