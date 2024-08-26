class ModRenameClashException implements Exception {
  const ModRenameClashException(this.renameTarget);
  final String renameTarget;

  @override
  String toString() => 'ModRenameClashException: $renameTarget';
}

class ShaderExistsException implements Exception {
  const ShaderExistsException(this.path);
  final String? path;

  @override
  String toString() => 'ShaderExistsException: $path';
}

class ShaderDeleteFailedException implements Exception {
  const ShaderDeleteFailedException(this.path);
  final String? path;

  @override
  String toString() => 'ShaderDeleteFailedException: $path';
}

class ModRenameFailedException implements Exception {
  const ModRenameFailedException();

  @override
  String toString() => 'ModRenameFailedException';
}
