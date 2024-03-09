import 'package:path/path.dart' as p;

const _disabledHeader = 'DISABLED';
const _disabledHeaderLength = _disabledHeader.length;

extension PathOps on String {
  String get pBasename => p.basename(this);

  String get pDirname => p.dirname(this);

  String get pExtension => p.extension(this);

  String get pBNameWoExt => p.basenameWithoutExtension(this);

  bool get pIsEnabled => !startsWith(_disabledHeader);

  String get pEnabledForm {
    if (!pIsEnabled) return substring(_disabledHeaderLength).trimLeft();
    return this;
  }

  String get pDisabledForm {
    if (pIsEnabled) return '$_disabledHeader ${trimLeft()}';
    return this;
  }

  bool pEquals(String other) => p.equals(this, other);

  String pJoin(String part2,
          [String? part3,
          String? part4,
          String? part5,
          String? part6,
          String? part7,
          String? part8,
          String? part9,
          String? part10,
          String? part11,
          String? part12,
          String? part13,
          String? part14,
          String? part15,
          String? part16]) =>
      p.join(this, part2, part3, part4, part5, part6, part7, part8, part9,
          part10, part11, part12, part13, part14, part15, part16);

  bool pIsWithin(String other) => p.isWithin(other, this);
}
