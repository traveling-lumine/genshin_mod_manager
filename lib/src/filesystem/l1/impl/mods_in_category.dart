import 'dart:io';

import 'package:rxdart/rxdart.dart';

import '../../l0/api/filesystem.dart';
import '../../l0/api/mods_in_category.dart';
import '../../l0/api/watcher.dart';
import '../../l0/entity/mod.dart';
import '../../l0/entity/mod_category.dart';
import 'fsops.dart';
import 'path_op_string.dart';

class ModsInCategoryImpl implements ModsInCategory {
  factory ModsInCategoryImpl({
    required final ModCategory category,
    required final Filesystem fs,
  }) {
    final fsStream = fs.watchDirectory(path: category.path);
    final debounceTime = fsStream.stream
        .where((final event) => event is! FileSystemModifyEvent)
        .debounceTime(const Duration(milliseconds: 100));
    final modsUnsorted = debounceTime.asyncMap(
      (final _) async => (await getUnder<Directory>(category.path))
          .map(
            (final e) => Mod(
              path: e,
              displayName: e.pEnabledForm.pBasename,
              isEnabled: e.pIsEnabled,
              category: category,
            ),
          )
          .toList(),
    );
    return ModsInCategoryImpl._(
      fsStream: fsStream,
      modsUnsorted: modsUnsorted,
    );
  }
  const ModsInCategoryImpl._({
    required this.fsStream,
    required this.modsUnsorted,
  });
  final Watcher fsStream;
  @override
  final Stream<List<Mod>> modsUnsorted;

  @override
  Future<void> dispose() async {
    await fsStream.cancel();
  }
}
