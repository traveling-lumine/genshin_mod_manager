import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../l0/api/ini_paths.dart';
import '../../l0/api/watcher.dart';
import '../../l0/entity/ini.dart';
import '../../l0/entity/mod.dart';
import '../helper.dart';

class IniPathsImpl implements IniPaths {
  factory IniPathsImpl({
    required final Mod mod,
    required final Watcher watcher,
  }) {
    final streamController = StreamController<List<IniFile>>();
    StreamSubscription<List<IniFile>>? subscription;

    unawaited(
      getValue(mod).then<void>(
        (final value) {
          if (streamController.isClosed) {
            return;
          }
          streamController.add(value);
          subscription =
              watcher.stream.asyncMap((final event) => getValue(mod)).listen(
                    streamController.add,
                    onError: streamController.addError,
                    onDone: streamController.close,
                  );
        },
      ).onError(streamController.addError),
    );

    return IniPathsImpl._(
      iniPaths: streamController.stream,
      onDispose: () async {
        await subscription?.cancel();
        await streamController.close();
      },
    );
  }

  const IniPathsImpl._({
    required this.iniPaths,
    this.onDispose,
  });

  final Future<void> Function()? onDispose;

  @override
  final Stream<List<IniFile>> iniPaths;

  @override
  Future<void> dispose() async {
    await onDispose?.call();
  }

  static Future<List<IniFile>> getValue(final Mod mod) async {
    final list = await pathsUnder<File>(mod.path);
    return list
        .where(
          (final e) => p.equals(p.extension(e), '.ini') && e.pIsEnabled,
        )
        .map(
          (final e) => IniFile(
            path: e,
            name: p.basename(e),
            mod: mod,
          ),
        )
        .toList();
  }
}
