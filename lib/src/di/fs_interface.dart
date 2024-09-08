import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../backend/fs_interface/data/repo/fs_interface.dart';
import '../backend/fs_interface/domain/repo/fs_interface.dart';
import '../backend/storage/domain/usecase/ini_editor_arg.dart';
import 'storage.dart';

part 'fs_interface.g.dart';

@riverpod
class FsInterface extends _$FsInterface {
  @override
  FileSystemInterface build() {
    final storage = ref.watch(persistentStorageProvider).requireValue;
    final fileSystemInterfaceImpl = FileSystemInterfaceImpl();
    initializeIniEditorArgumentUseCase(storage, fileSystemInterfaceImpl);
    return fileSystemInterfaceImpl;
  }

  void setIniEditorArgument(final String? arg) {
    final storage = ref.read(persistentStorageProvider).requireValue;
    setIniEditorArgumentUseCase(storage, state, arg);
  }
}
