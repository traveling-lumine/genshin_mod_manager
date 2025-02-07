import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../l0/api/filesystem.dart';
import '../impl/filesystem.dart';

part 'filesystem.g.dart';

@riverpod
Filesystem filesystem(final Ref ref) {
  final filesystemImpl = FilesystemImpl();
  ref.onDispose(filesystemImpl.dispose);
  return filesystemImpl;
}
