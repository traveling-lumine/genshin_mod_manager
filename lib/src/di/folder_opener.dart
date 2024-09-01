import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../backend/fs_interface/data/repo/folder_opener.dart' as s;
import '../backend/fs_interface/domain/repo/folder_opener.dart';

part 'folder_opener.g.dart';

@riverpod
FolderOpener folderOpener(final FolderOpenerRef ref) => s.folderOpener;
