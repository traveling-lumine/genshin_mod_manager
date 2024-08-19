import 'package:genshin_mod_manager/data/repo/fs_interface.dart';
import 'package:genshin_mod_manager/domain/repo/fs_interface.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fs_interface.g.dart';

@riverpod
FileSystemInterface fsInterface(final FsInterfaceRef ref) =>
    FileSystemInterfaceImpl();
