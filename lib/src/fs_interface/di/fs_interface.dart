import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../storage/di/storage.dart';
import '../../storage/l0/usecase/ini_editor_arg.dart';
import '../repo/fs_interface.dart';

part 'fs_interface.g.dart';

@riverpod
class FsInterface extends _$FsInterface {
  @override
  FileSystemInterface build() {
    final storage = ref.watch(persistentStorageProvider).requireValue;
    final fileSystemInterface = FileSystemInterface();
    initializeIniEditorArgumentUseCase(storage, fileSystemInterface);
    return fileSystemInterface;
  }

  void setIniEditorArgument(final String? arg) {
    final storage = ref.read(persistentStorageProvider).requireValue;
    setIniEditorArgumentUseCase(storage, state, arg);
  }
}
