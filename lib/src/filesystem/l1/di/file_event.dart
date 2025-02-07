import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../l0/api/file_event.dart';
import '../impl/file_event.dart';
import 'filesystem.dart';

part 'file_event.g.dart';

@riverpod
FileEvent fileEvent(final Ref ref, {required final String path}) {
  final fs = ref.watch(filesystemProvider);
  final fileEventImpl = FileEventImpl(fs: fs, path: path);
  ref.onDispose(fileEventImpl.cancel);
  return fileEventImpl;
}
