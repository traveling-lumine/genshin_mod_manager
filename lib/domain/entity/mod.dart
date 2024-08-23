import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'mod_category.dart';

part 'mod.freezed.dart';

@freezed
class Mod with _$Mod {
  const factory Mod({
    required final String path,
    required final String displayName,
    required final bool isEnabled,
    required final ModCategory category,
  }) = _Mod;
}
