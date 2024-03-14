import 'package:meta/meta.dart';

@immutable
final class FSEvent {
  const FSEvent({
    required this.paths,
    this.force = false,
  });

  final List<String> paths;
  final bool force;

  @override
  String toString() => 'FSEvent{paths: $paths, force: $force}';
}
