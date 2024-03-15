import 'dart:io';

import 'package:meta/meta.dart';

@immutable
final class FSEvent {
  const FSEvent({
    this.event,
    this.force = false,
  });

  final FileSystemEvent? event;
  final bool force;

  @override
  String toString() => 'FSEvent{paths: $event, force: $force}';
}
