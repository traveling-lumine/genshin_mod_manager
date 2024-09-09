// JsonKey issue
// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entity/nahida_element.dart';

part 'akasha_single_fetch_result.freezed.dart';
part 'akasha_single_fetch_result.g.dart';

@freezed
class AkashaSingleFetchResult with _$AkashaSingleFetchResult {
  const factory AkashaSingleFetchResult({
    required final bool success,
    required final String action,
    @JsonKey(name: 'data') required final NahidaliveElement result,
  }) = _AkashaSingleFetchResult;

  factory AkashaSingleFetchResult.fromJson(final Map<String, dynamic> json) =>
      _$AkashaSingleFetchResultFromJson(json);
}
