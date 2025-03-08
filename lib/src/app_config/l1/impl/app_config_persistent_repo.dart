import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';

import '../../l0/api/app_config_persistent_repo.dart';
import '../../l0/api/basic_path.dart';
import '../../l0/entity/app_config.dart';

class AppConfigPersistentRepoImpl implements AppConfigPersistentRepo {
  factory AppConfigPersistentRepoImpl({
    required final BasicPathProvider basicPath,
  }) {
    final controller = StreamController<AppConfig>();
    StreamSubscription<AppConfig>? subscription;

    final settingsFile = basicPath.settingFile;
    final didFileExist = settingsFile.existsSync();

    unawaited(
      settingsFile.create().then<void>(
        (final value) async {
          if (!didFileExist) {
            await settingsFile.writeAsString('{}');
          }
          final value = await _getValue(settingsFile);
          if (controller.isClosed) {
            return;
          }
          controller.add(value);
          subscription = settingsFile.parent
              .watch()
              .debounceTime(const Duration(milliseconds: 500))
              .where((final event) {
                if (p.equals(event.path, settingsFile.path)) {
                  return true;
                }
                if (event is FileSystemMoveEvent) {
                  final dest = event.destination;
                  if (dest != null) {
                    return p.equals(dest, settingsFile.path);
                  }
                }
                return false;
              })
              .asyncMap((final _) => _getValue(settingsFile))
              .distinct()
              .listen(
                controller.add,
                onError: controller.addError,
                onDone: controller.close,
              );
        },
      ).onError(controller.addError),
    );

    return AppConfigPersistentRepoImpl._(
      onDispose: () async {
        await subscription?.cancel();
        await controller.close();
      },
      stream: controller.stream,
      basicPath: basicPath,
    );
  }

  AppConfigPersistentRepoImpl._({
    required this.stream,
    required this.onDispose,
    required this.basicPath,
  });

  static const _encoder = JsonEncoder.withIndent('  ');

  final BasicPathProvider basicPath;
  @override
  final Stream<AppConfig> stream;

  final Future<void> Function() onDispose;

  @override
  Future<void> dispose() async {
    await onDispose();
  }

  @override
  Future<void> save(final AppConfig value) async {
    await basicPath.settingFile.writeAsString(_encoder.convert(value));
  }

  static Future<AppConfig> _getValue(final File settingFile) async =>
      AppConfig.fromJson(
        jsonDecode(await settingFile.readAsString()) as Map<String, dynamic>,
      );
}
