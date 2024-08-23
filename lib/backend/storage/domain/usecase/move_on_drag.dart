import '../persistent_storage.dart';

const moveOnDragKey = 'moveOnDrag';
const moveOnDragDefault = true;

bool initializeMoveOnDragUseCase(final PersistentStorage watch) =>
    watch.getBool(moveOnDragKey) ?? moveOnDragDefault;
void setMoveOnDragUseCase(final PersistentStorage read, final bool value) =>
    read.setBool(moveOnDragKey, value);
