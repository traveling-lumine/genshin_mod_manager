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

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! FSEvent) {
      return false;
    }

    var listEquals = false;
    if (paths.length == other.paths.length) {
      listEquals = true;
      for (var i = 0; i < paths.length; i++) {
        if (paths[i] != other.paths[i]) {
          listEquals = false;
          break;
        }
      }
    }

    return listEquals && force == other.force;
  }

  @override
  int get hashCode => paths.hashCode ^ force.hashCode;
}
