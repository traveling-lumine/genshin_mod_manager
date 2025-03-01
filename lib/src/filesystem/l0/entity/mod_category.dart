import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mod_category.freezed.dart';

@freezed
sealed class ModCategory with _$ModCategory {
  factory ModCategory({
    required final String path,
    required final String name,
  }) = _ModCategory;
}
