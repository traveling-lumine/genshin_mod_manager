import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../l0/api/mods_in_category.dart';
import '../../l0/api/watcher.dart';
import '../../l0/entity/mod.dart';
import '../../l0/entity/mod_category.dart';
import '../helper.dart';

class ModsInCategoryImpl implements ModsInCategory {
  factory ModsInCategoryImpl({
    required final ModCategory category,
    required final Watcher watcher,
  }) {
    final streamController = StreamController<List<Mod>>();
    StreamSubscription<List<Mod>>? subscription;

    unawaited(
      getValue(category).then<void>(
        (final value) {
          if (streamController.isClosed) {
            return;
          }
          streamController.add(value);
          subscription = watcher.stream
              .where((final event) => event is! FileSystemModifyEvent)
              .asyncMap(
                (final _) => getValue(category),
              )
              .listen(
                streamController.add,
                onError: streamController.addError,
                onDone: streamController.close,
              );
        },
      ).catchError(streamController.addError),
    );

    return ModsInCategoryImpl._(
      modsInCategory: streamController.stream,
      onDispose: () async {
        await subscription?.cancel();
        await streamController.close();
      },
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

  static Future<List<Mod>> getValue(final ModCategory category) async {
    final list = await pathsUnder<Directory>(category.path);
    return list
        .map(
          (final e) => Mod(
            path: e,
            displayName: p.basename(e.pEnabledForm),
            isEnabled: e.pIsEnabled,
            category: category,
          ),
        )
        .toList();
  }
}
