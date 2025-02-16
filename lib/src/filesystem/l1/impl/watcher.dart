import 'dart:async';
import 'dart:io';

import '../../l0/api/watcher.dart';

class FSSubscription implements Watcher {
  const FSSubscription({
    required this.stream,
    required this.onCancel,
  });

  @override
  final Stream<FileSystemEvent?> stream;
  final Future<void> Function() onCancel;

  @override
  Future<void> cancel() async {
    await onCancel();
  }
}
