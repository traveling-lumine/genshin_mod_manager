// JsonKey issue
// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entity/nahida_element.dart';
import '../secrets.dart';

part 'akasha_page_result.freezed.dart';
part 'akasha_page_result.g.dart';

@freezed
class AkashaPageResult with _$AkashaPageResult {
  const factory AkashaPageResult({
    @JsonKey(name: Env.val2) required final int elementsPerPage,
    @JsonKey(name: Env.val14) required final int currentPage,
    @JsonKey(name: Env.val15) required final int totalPage,
    @JsonKey(name: Env.val16) required final int totalElements,
    @JsonKey(name: Env.val4) required final List<NahidaliveElement> elements,
  }) = _AkashaPageResult;

  factory AkashaPageResult.fromJson(final Map<String, dynamic> json) =>
      _$AkashaPageResultFromJson(json);
}
