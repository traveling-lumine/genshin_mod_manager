import '../api/persistent_storage.dart';
import '../constants.dart';

final moveOnDragKey = StorageAccessKey.moveOnDrag.name;
const moveOnDragDefault = true;

bool initializeMoveOnDragUseCase(final PersistentStorage? watch) =>
    watch?.getBool(moveOnDragKey) ?? moveOnDragDefault;
void setMoveOnDragUseCase(final PersistentStorage? read, final bool value) =>
    read?.setBool(moveOnDragKey, value);
