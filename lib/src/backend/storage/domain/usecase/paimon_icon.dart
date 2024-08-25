import '../repo/persistent_storage.dart';

const showPaimonIconKey = 'showPaimonAsEmptyIconFolderIcon';
const showPaimonIconDefault = true;

bool initializePaimonIconUseCase(final PersistentStorage watch) =>
    watch.getBool(showPaimonIconKey) ?? showPaimonIconDefault;
void setPaimonIconUseCase(final PersistentStorage read, final bool value) =>
    read.setBool(showPaimonIconKey, value);
