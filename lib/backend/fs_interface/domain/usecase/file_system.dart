import '../fs_interface.dart';

Future<void> openFolderUseCase(
  final FileSystemInterface fsInterface,
  final String path,
) async {
  await fsInterface.openFolder(path);
}
