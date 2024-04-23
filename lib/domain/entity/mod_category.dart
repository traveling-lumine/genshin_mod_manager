import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mod_category.freezed.dart';
part 'mod_category.g.dart';

@freezed
class ModCategory with _$ModCategory {
  const factory ModCategory({
    required final String path,
    required final String name,
    final String? iconPath,
  }) = _ModCategory;

  factory ModCategory.fromJson(final Map<String, dynamic> json) =>
      _$ModCategoryFromJson(json);
}

/// A codec for [ModCategory].
class ModCategoryCodec extends Codec<ModCategory?, String?> {
  /// Creates a [ModCategoryCodec].
  const ModCategoryCodec();

  @override
  Converter<String?, ModCategory?> get decoder => const _Decoder();

  @override
  Converter<ModCategory?, String?> get encoder => const _Encoder();
}

class _Encoder extends Converter<ModCategory?, String?> {
  const _Encoder();

  @override
  String? convert(final ModCategory? input) {
    if (input == null) {
      return null;
    }
    return jsonEncode(input.toJson());
  }
}

class _Decoder extends Converter<String?, ModCategory?> {
  const _Decoder();

  @override
  ModCategory? convert(final String? input) {
    if (input == null) {
      return null;
    }
    return ModCategory.fromJson(jsonDecode(input));
  }
}
