import '../repo/persistent_storage.dart';

const showFolderIconKey = 'showFolderIcon';
const showFolderIconDefault = true;

bool initializeFolderIconUseCase(final PersistentStorage? watch) =>
    watch?.getBool(showFolderIconKey) ?? showFolderIconDefault;
void setFolderIconUseCase(final PersistentStorage? read, final bool value) =>
    read?.setBool(showFolderIconKey, value);
