import 'dart:io';

import 'package:collection/collection.dart';
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
    required final bool enabledModsFirst,
    required final Filesystem fs,
  }) {
    final fsStream = fs.watchDirectory(path: category.path);
    return ModsInCategoryImpl._(
      fsStream: fsStream,
      mods: fsStream.stream
          .where((final event) => event is! FileSystemModifyEvent)
          .debounceTime(const Duration(milliseconds: 100))
          .asyncMap(
            (final _) async => modsInCategory(
              category: category,
              enabledModsFirst: enabledModsFirst,
            ),
          ),
    );
  }
  const ModsInCategoryImpl._({
    required this.fsStream,
    required this.mods,
  });

  final Watcher fsStream;
  @override
  final Stream<List<Mod>> mods;

  @override
  Future<void> dispose() async {
    await fsStream.cancel();
  }

  static Future<List<Mod>> modsInCategory({
    required final ModCategory category,
    required final bool enabledModsFirst,
  }) async {
    final under = await getUnder<Directory>(category.path);
    return under
        .map(
          (final e) => Mod(
            path: e,
            displayName: e.pEnabledForm.pBasename,
            isEnabled: e.pIsEnabled,
            category: category,
          ),
        )
        .toList()
      ..sort((final a, final b) {
        if (enabledModsFirst) {
          final aEnabled = a.isEnabled;
          final bEnabled = b.isEnabled;
          if (aEnabled && !bEnabled) {
            return -1;
          } else if (!aEnabled && bEnabled) {
            return 1;
          }
        }
        return compareNatural(a.displayName, b.displayName);
      });
  }
}
