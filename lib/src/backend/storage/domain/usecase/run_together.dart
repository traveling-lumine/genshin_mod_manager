import '../persistent_storage.dart';

const runTogetherKey = 'runTogether';
const runTogetherDefault = false;

bool initializeRunTogetherUseCase(final PersistentStorage watch) =>
    watch.getBool(runTogetherKey) ?? runTogetherDefault;

void setRunTogetherUseCase(final PersistentStorage read, final bool value) =>
    read.setBool(runTogetherKey, value);
