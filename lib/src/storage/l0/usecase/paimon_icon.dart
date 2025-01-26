import '../constants.dart';
import '../api/persistent_storage.dart';

final showPaimonIconKey = StorageAccessKey.showPaimonAsEmptyIconFolderIcon.name;
const showPaimonIconDefault = true;

bool initializePaimonIconUseCase(final PersistentStorage? watch) =>
    watch?.getBool(showPaimonIconKey) ?? showPaimonIconDefault;
void setPaimonIconUseCase(final PersistentStorage? read, final bool value) =>
    read?.setBool(showPaimonIconKey, value);
