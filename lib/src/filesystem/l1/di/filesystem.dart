import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app_config/l1/di/basic_path.dart';
import '../../l0/api/filesystem.dart';
import '../impl/filesystem.dart';

part 'filesystem.g.dart';

@riverpod
Filesystem filesystem(final Ref ref) {
  final filesystemImpl =
      FilesystemImpl(basicPathProvider: ref.watch(basicPathProvider));
  ref.onDispose(filesystemImpl.dispose);
  return filesystemImpl;
}
