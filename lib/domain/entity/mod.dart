import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:meta/meta.dart';

@immutable
class Mod {
  const Mod({
    required this.path,
    required this.displayName,
    required this.isEnabled,
    required this.category,
  });

  final String path;
  final String displayName;
  final bool isEnabled;
  final ModCategory category;

  @override
  String toString() =>
      'Mod{path: $path, displayName: $displayName, isEnabled: $isEnabled, category: $category}';

  @override
  bool operator ==(final Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Mod &&
        other.path == path &&
        other.displayName == displayName &&
        other.isEnabled == isEnabled &&
        other.category == category;
  }

  @override
  int get hashCode =>
      path.hashCode ^
      displayName.hashCode ^
      isEnabled.hashCode ^
      category.hashCode;
}
