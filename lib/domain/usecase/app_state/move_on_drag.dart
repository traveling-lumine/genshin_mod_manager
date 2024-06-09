import 'package:genshin_mod_manager/domain/constant.dart';
import 'package:genshin_mod_manager/domain/repo/persistent_storage.dart';

bool initializeMoveOnDragUseCase(final PersistentStorage watch) =>
    watch.getBool(moveOnDragKey) ?? moveOnDragDefault;
void setMoveOnDragUseCase(final PersistentStorage read, final bool value) =>
    read.setBool(moveOnDragKey, value);
