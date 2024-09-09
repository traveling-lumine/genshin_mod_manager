// JsonKey issue
// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'akasha_page_result.dart';

part 'akasha_page_fetch_result.freezed.dart';
part 'akasha_page_fetch_result.g.dart';

@freezed
class AkashaPageFetchResult with _$AkashaPageFetchResult {
  const factory AkashaPageFetchResult({
    required final bool success,
    required final String action,
    @JsonKey(name: 'data') required final AkashaPageResult result,
  }) = _AkashaPageFetchResult;

  factory AkashaPageFetchResult.fromJson(final Map<String, dynamic> json) =>
      _$AkashaPageFetchResultFromJson(json);
}
