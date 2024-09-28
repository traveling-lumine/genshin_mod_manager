import '../constants.dart';
import '../repo/persistent_storage.dart';

final runTogetherKey = StorageAccessKey.runTogether.name;
const runTogetherDefault = false;

bool initializeRunTogetherUseCase(final PersistentStorage? watch) =>
    watch?.getBool(runTogetherKey) ?? runTogetherDefault;

void setRunTogetherUseCase(final PersistentStorage? read, final bool value) =>
    read?.setBool(runTogetherKey, value);
