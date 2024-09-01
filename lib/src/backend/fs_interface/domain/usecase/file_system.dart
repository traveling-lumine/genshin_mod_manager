import '../repo/folder_opener.dart';

Future<void> openFolderUseCase(
  final FolderOpener opener,
  final String path,
) =>
    opener(path);
