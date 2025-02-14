import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';

import '../../l0/api/app_config_persistent_repo.dart';
import '../entity/app_config.dart';

class AppConfigPersistentRepoImpl implements AppConfigPersistentRepo {
  factory AppConfigPersistentRepoImpl() {
    // the class will close this
    // ignore: close_sinks
    final controller = BehaviorSubject<Map<String, dynamic>>();

    final mergeStream = MergeStream([
      Stream.value(null),
      Directory.current.watch().where(
        (final event) {
          if (p.equals(event.path, _settingsFile.path)) {
            return true;
          }
          if (event is FileSystemMoveEvent) {
            final dest = event.destination;
            if (dest != null) {
              return p.equals(dest, _settingsFile.path);
            }
          }
          return false;
        },
      ).debounceTime(const Duration(milliseconds: 500)),
    ]).asyncMap(
      (final _) async => jsonDecode(await _settingsFile.readAsString())
          as Map<String, dynamic>,
    );

    // the class will close this
    // ignore: cancel_subscriptions
    final subscription =
        // silently ignore errors
        mergeStream.listen(controller.add, onError: (final _) {});
    return AppConfigPersistentRepoImpl._(subscription, controller);
  }
  AppConfigPersistentRepoImpl._(this._subscription, this._controller);
  static final _settingsFile = File('settings.json');
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
    await _settingsFile.writeAsString(_encoder.convert(value));
  }
}
