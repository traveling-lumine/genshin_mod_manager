import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../backend/fs_interface/domain/entity/setting_data.dart';
import '../../backend/storage/domain/usecase/move_on_drag.dart';
import '../storage.dart';
import 'value_settable.dart';

part 'move_on_drag.g.dart';

@riverpod
class MoveOnDrag extends _$MoveOnDrag implements ValueSettable<DragImportType> {
  @override
  DragImportType build() {
    final watch = ref.watch(persistentStorageProvider).valueOrNull;
    return initializeMoveOnDragUseCase(watch)
        ? DragImportType.move
        : DragImportType.copy;
  }

  @override
  void setValue(final DragImportType value) {
    final read = ref.read(persistentStorageProvider).valueOrNull;
    final boolValue = value == DragImportType.move;
    setMoveOnDragUseCase(read, boolValue);
    state = value;
  }
}
