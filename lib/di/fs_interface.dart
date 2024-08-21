import 'package:genshin_mod_manager/data/repo/fs_interface.dart';
import 'package:genshin_mod_manager/di/storage.dart';
import 'package:genshin_mod_manager/domain/repo/fs_interface.dart';
import 'package:genshin_mod_manager/domain/usecase/app_state/ini_editor_arg.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fs_interface.g.dart';

@riverpod
class FsInterface extends _$FsInterface {
  @override
  FileSystemInterface build() {
    final fileSystemInterfaceImpl = FileSystemInterfaceImpl();
    final storage = ref.watch(sharedPreferenceStorageProvider);
    initializeIniEditorArgumentUseCase(storage, fileSystemInterfaceImpl);
    return fileSystemInterfaceImpl;
  }

  void setIniEditorArgument(final String? arg) {
    final storage = ref.read(sharedPreferenceStorageProvider);
    setIniEditorArgumentUseCase(storage, state, arg);
  }
}
