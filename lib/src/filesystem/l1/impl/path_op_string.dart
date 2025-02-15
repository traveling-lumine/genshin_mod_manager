import 'package:path/path.dart' as p;

const _disabledHeader = 'DISABLED';
const _disabledHeaderLength = _disabledHeader.length;

/// Extension on [String] to provide path operations.
extension PathOpString on String {
  /// Returns the last part of the path.
  String get pBasename => p.basename(this);

  /// Returns the file name without extension.
  String get pBNameWoExt => p.basenameWithoutExtension(this);

  /// Returns the directory part of the path.
  String get pDirname => p.dirname(this);

  /// Returns the path in disabled form.
  String get pDisabledForm {
    var baseName = pBasename;
    if (baseName.pIsEnabled) {
      baseName = '$_disabledHeader ${baseName.trimLeft()}';
    }
    if (p.split(this).length == 1) {
      return baseName;
    } else {
      return pDirname.pJoin(baseName);
    }
  }

  /// Returns the path in enabled form.
  String get pEnabledForm {
    var baseName = pBasename;
    while (!baseName.pIsEnabled) {
      baseName = baseName.substring(_disabledHeaderLength).trimLeft();
    }
    if (p.split(this).length == 1) {
      return baseName;
    } else {
      return pDirname.pJoin(baseName);
    }
  }

  /// Returns the extension part of the path.
  String get pExtension => p.extension(this);

  /// Returns whether the path is enabled.
  bool get pIsEnabled =>
      !pBasename.toLowerCase().startsWith(_disabledHeader.toLowerCase());

  /// Returns whether the paths are equal.
  bool pEquals(final String other) => p.equals(this, other);

  /// Check whether this path is contained in [other].
  bool pIsWithin(final String other) => p.isWithin(other, this);

  /// Join the path with the given parts.
  String pJoin(
    final String part2, [
    final String? part3,
    final String? part4,
    final String? part5,
    final String? part6,
    final String? part7,
    final String? part8,
    final String? part9,
    final String? part10,
    final String? part11,
    final String? part12,
    final String? part13,
    final String? part14,
    final String? part15,
    final String? part16,
  ]) =>
      p.join(
        this,
        part2,
        part3,
        part4,
        part5,
        part6,
        part7,
        part8,
        part9,
        part10,
        part11,
        part12,
        part13,
        part14,
        part15,
        part16,
      );
}
