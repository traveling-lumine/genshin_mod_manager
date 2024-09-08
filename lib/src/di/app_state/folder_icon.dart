import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../backend/storage/domain/usecase/folder_icon.dart';
import '../storage.dart';
import 'value_settable.dart';

part 'folder_icon.g.dart';

@riverpod
class FolderIcon extends _$FolderIcon implements ValueSettable<bool> {
  @override
  bool build() {
    final watch = ref.watch(persistentStorageProvider).valueOrNull;
    return initializeFolderIconUseCase(watch);
  }

  @override
  void setValue(final bool value) {
    final read = ref.read(persistentStorageProvider).valueOrNull;
    setFolderIconUseCase(read, value);
    state = value;
  }
}
