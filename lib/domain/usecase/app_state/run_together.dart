import 'package:genshin_mod_manager/domain/constant.dart';
import 'package:genshin_mod_manager/domain/repo/persistent_storage.dart';

bool initializeRunTogetherUseCase(final PersistentStorage watch) =>
    watch.getBool(runTogetherKey) ?? runTogetherDefault;

void setRunTogetherUseCase(final PersistentStorage read, final bool value) =>
    read.setBool(runTogetherKey, value);
