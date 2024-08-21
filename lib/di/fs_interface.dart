import 'package:genshin_mod_manager/data/repo/fs_interface.dart';
import 'package:genshin_mod_manager/domain/repo/fs_interface.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fs_interface.g.dart';

@riverpod
class FsInterface extends _$FsInterface {
  @override
  FileSystemInterface build() => FileSystemInterfaceImpl();

  void setIniEditorArgument(final String arg) {
    final replaced =
        arg.split(' ').map((final e) => e == '%0' ? null : e).toList();
    state.setIniEditorArgument(replaced);
  }
}
