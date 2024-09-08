import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mod_category.freezed.dart';
part 'mod_category.g.dart';

@freezed
class ModCategory with _$ModCategory {
  const factory ModCategory({
    required final String path,
    required final String name,
  }) = _ModCategory;

  factory ModCategory.fromJson(final Map<String, dynamic> json) =>
      _$ModCategoryFromJson(json);
}
