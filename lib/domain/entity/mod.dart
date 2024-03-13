class Mod {
  final String path;
  final String displayName;
  final bool isEnabled;

  const Mod({
    required this.path,
    required this.displayName,
    required this.isEnabled,
  });

  @override
  String toString() {
    return 'Mod(path: $path, displayName: $displayName, isEnabled: $isEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Mod &&
        other.path == path &&
        other.displayName == displayName &&
        other.isEnabled == isEnabled;
  }

  @override
  int get hashCode => path.hashCode ^ displayName.hashCode ^ isEnabled.hashCode;
}
