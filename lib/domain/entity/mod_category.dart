class ModCategory {
  final String path;
  final String name;
  final String? iconPath;

  ModCategory({
    required this.path,
    required this.name,
    this.iconPath,
  });

  @override
  String toString() {
    return 'ModCategory(path: $path, name: $name, iconPath: $iconPath)';
  }
}
