import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';

import '../../l0/api/app_config_persistent_repo.dart';
import '../../l0/entity/app_config.dart';

class AppConfigPersistentRepoImpl implements AppConfigPersistentRepo {
  factory AppConfigPersistentRepoImpl() {
    // the class will close this
    // ignore: close_sinks
    final controller = BehaviorSubject<Map<String, dynamic>>();

    final mergeStream = MergeStream([
      Stream.value(null),
      Directory.current.watch().where((final event) {
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
      }).debounceTime(const Duration(milliseconds: 500)),
    ]).asyncMap(
      (final _) async =>
          jsonDecode(await settingsFile.readAsString()) as Map<String, dynamic>,
    );

    // the class will close this
    // ignore: cancel_subscriptions
    final subscription = mergeStream.listen(
      controller.add,
      onError: (final Object e, final StackTrace? st) => controller.hasValue
          ? controller.add(controller.value)
          : controller.addError(e, st),
    );
    return AppConfigPersistentRepoImpl._(subscription, controller);
  }
  AppConfigPersistentRepoImpl._(this._subscription, this._controller);
  static final settingsFile = File(
      p.join(File(Platform.resolvedExecutable).parent.path, 'settings.json'),);
  static const _encoder = JsonEncoder.withIndent('  ');
  final StreamSubscription<Map<String, dynamic>> _subscription;
  final BehaviorSubject<Map<String, dynamic>> _controller;

  @override
  Stream<Map<String, dynamic>> get stream =>
      _controller.stream.distinct(const DeepCollectionEquality().equals);

  @override
  Future<void> dispose() async {
    await Future.wait([
      _subscription.cancel(),
      _controller.close(),
    ]);
  }

  @override
  Future<void> save(final AppConfig value) async {
    await settingsFile.writeAsString(_encoder.convert(value));
  }
}
