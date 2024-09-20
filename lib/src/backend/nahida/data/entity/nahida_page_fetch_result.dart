// JsonKey issue
// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'nahida_page_result.dart';

part 'nahida_page_fetch_result.freezed.dart';
part 'nahida_page_fetch_result.g.dart';

@freezed
class NahidaPageFetchResult with _$NahidaPageFetchResult {
  const factory NahidaPageFetchResult({
    required final bool success,
    required final String action,
    @JsonKey(name: 'data') required final NahidaPageResult result,
  }) = _NahidaPageFetchResult;

  factory NahidaPageFetchResult.fromJson(final Map<String, dynamic> json) =>
      _$NahidaPageFetchResultFromJson(json);
}
