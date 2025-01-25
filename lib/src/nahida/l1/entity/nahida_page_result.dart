// JsonKey issue
// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../l0/entity/nahida_element.dart';

part 'nahida_page_result.freezed.dart';
part 'nahida_page_result.g.dart';

@freezed
class NahidaPageQueryResult with _$NahidaPageQueryResult {
  const factory NahidaPageQueryResult({
    required final bool success,
    required final NahidaPageResult data,
  }) = _NahidaPageQueryResult;

  factory NahidaPageQueryResult.fromJson(final Map<String, dynamic> json) =>
      _$NahidaPageQueryResultFromJson(json);
}

@freezed
class NahidaPageResult with _$NahidaPageResult {
  const factory NahidaPageResult({
    @JsonKey(name: 'ps') required final int elementsPerPage,
    @JsonKey(name: 'cp') required final int currentPage,
    @JsonKey(name: 'tp') required final int totalPage,
    @JsonKey(name: 'ti') required final int totalElements,
    @JsonKey(name: 'r') required final List<NahidaliveElement> elements,
  }) = _NahidaPageResult;

  factory NahidaPageResult.fromJson(final Map<String, dynamic> json) =>
      _$NahidaPageResultFromJson(json);
}
