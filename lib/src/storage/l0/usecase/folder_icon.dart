import '../constants.dart';
import '../api/persistent_storage.dart';

final showFolderIconKey = StorageAccessKey.showFolderIcon.name;
const showFolderIconDefault = true;

bool initializeFolderIconUseCase(final PersistentStorage? watch) =>
    watch?.getBool(showFolderIconKey) ?? showFolderIconDefault;
void setFolderIconUseCase(final PersistentStorage? read, final bool value) =>
    read?.setBool(showFolderIconKey, value);
