// JsonKey issue
// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entity/nahida_element.dart';

part 'nahida_single_fetch_result.freezed.dart';
part 'nahida_single_fetch_result.g.dart';

@freezed
class NahidaSingleFetchResult with _$NahidaSingleFetchResult {
  const factory NahidaSingleFetchResult({
    required final bool success,
    @JsonKey(name: 'mod') required final NahidaliveElement result,
  }) = _NahidaSingleFetchResult;

  factory NahidaSingleFetchResult.fromJson(final Map<String, dynamic> json) =>
      _$NahidaSingleFetchResultFromJson(json);
}
