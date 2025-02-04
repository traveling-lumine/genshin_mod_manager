import 'dart:async';
import 'dart:io';

import '../../l0/api/watcher.dart';

class FSSubscription implements Watcher {
  const FSSubscription({
    required this.wrappee,
    required this.onCancel,
  });

  final StreamSubscription<FileSystemEvent?> wrappee;
  final Future<void> Function() onCancel;

  @override
  Future<void> cancel() async {
    await Future.wait<void>([wrappee.cancel(), onCancel()]);
  }
}
