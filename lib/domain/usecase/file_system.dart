import 'package:genshin_mod_manager/domain/repo/fs_interface.dart';

Future<void> openFolderUseCase(
  final FileSystemInterface fsInterface,
  final String path,
) async {
  await fsInterface.openFolder(path);
}
