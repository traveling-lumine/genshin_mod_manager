import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';

import '../../l0/api/filesystem.dart';
import '../../l0/api/mods_in_category.dart';
import '../../l0/entity/mod.dart';
import '../../l0/entity/mod_category.dart';
import '../helper.dart';

class ModsInCategoryImpl implements ModsInCategory {
  factory ModsInCategoryImpl({
    required final ModCategory category,
    required final Filesystem fs,
  }) {
    final watcher = fs.watchDirectory(path: category.path);

    return ModsInCategoryImpl._(
      modsInCategory: watcher.stream
          .where((final event) => event is! FileSystemModifyEvent)
          .debounceTime(const Duration(milliseconds: 100))
          .asyncMap(
            (final _) async => (await pathsUnder<Directory>(category.path))
                .map(
                  (final e) => Mod(
                    path: e,
                    displayName: p.basename(e.pEnabledForm),
                    isEnabled: e.pIsEnabled,
                    category: category,
                  ),
                )
                .toList(),
          ),
      onDispose: watcher.cancel,
    );
  }

  const ModsInCategoryImpl._({
    required this.modsInCategory,
    this.onDispose,
  });

  final Future<void> Function()? onDispose;

  @override
  final Stream<List<Mod>> modsInCategory;

  @override
  Future<void> dispose() async {
    await onDispose?.call();
  }
}
