class Mod {
  final String path;

  Mod({required this.path});

  @override
  String toString() {
    return 'Mod('
        'path: $path'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mod && other.path == path;
  }

  @override
  int get hashCode {
    return path.hashCode;
  }
}
