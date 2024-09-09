// JsonKey issue
// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entity/nahida_element.dart';

part 'akasha_page_result.freezed.dart';
part 'akasha_page_result.g.dart';

@freezed
class AkashaPageResult with _$AkashaPageResult {
  const factory AkashaPageResult({
    @JsonKey(name: 'ps') required final int elementsPerPage,
    @JsonKey(name: 'cp') required final int currentPage,
    @JsonKey(name: 'tp') required final int totalPage,
    @JsonKey(name: 'ti') required final int totalElements,
    @JsonKey(name: 'r') required final List<NahidaliveElement> elements,
  }) = _AkashaPageResult;

  factory AkashaPageResult.fromJson(final Map<String, dynamic> json) =>
      _$AkashaPageResultFromJson(json);
}
