import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';

import '../../l0/api/app_config_persistent_repo.dart';
import '../../l0/entity/app_config.dart';

class AppConfigPersistentRepoImpl implements AppConfigPersistentRepo {
  factory AppConfigPersistentRepoImpl() {
    final controller = StreamController<AppConfig>();
    StreamSubscription<AppConfig>? subscription;

    final didFileExist = settingsFile.existsSync();

    unawaited(
      settingsFile.create().then<void>(
        (final value) async {
          if (!didFileExist) {
            await settingsFile.writeAsString('{}');
          }
          final value = await _getValue();
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
              .asyncMap((final _) => _getValue())
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
    );
  }

  AppConfigPersistentRepoImpl._({
    required this.stream,
    required this.onDispose,
  });

  static final Directory executableDir =
      File(Platform.resolvedExecutable).parent;

  static final settingsFile = File(
    p.join(File(Platform.resolvedExecutable).parent.path, 'settings.json'),
  );

  static const _encoder = JsonEncoder.withIndent('  ');
  @override
  final Stream<AppConfig> stream;

  final Future<void> Function() onDispose;

  @override
  Future<void> dispose() async {
    await onDispose();
  }

  @override
  Future<void> save(final AppConfig value) async {
    await settingsFile.writeAsString(_encoder.convert(value));
  }

  static Future<AppConfig> _getValue() async => AppConfig.fromJson(
        jsonDecode(await settingsFile.readAsString()) as Map<String, dynamic>,
      );
}
