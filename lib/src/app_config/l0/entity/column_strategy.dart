import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'column_strategy.freezed.dart';
part 'column_strategy.g.dart';

@freezed
sealed class ColumnStrategyEnum with _$ColumnStrategyEnum {
  const factory ColumnStrategyEnum.fixedCount(final int numChildren) =
      ColumnStrategyFixedCount;

  const factory ColumnStrategyEnum.maxExtent(final int extent) =
      ColumnStrategyMaxExtent;

  const factory ColumnStrategyEnum.minExtent(final int extent) =
      ColumnStrategyMinExtent;
}

enum ColumnStrategyEnumType {
  fixedCount,
  maxExtent,
  minExtent,
}

@freezed
class ColumnStrategySettingMediator with _$ColumnStrategySettingMediator {
  // annotation is valid.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory ColumnStrategySettingMediator({
    required final ColumnStrategyEnumType current,
    required final int fixedCount,
    required final int maxExtent,
    required final int minExtent,
  }) = _ColumnStrategySettingMediator;

  factory ColumnStrategySettingMediator.fromJson(
    final Map<String, dynamic> json,
  ) =>
      _$ColumnStrategySettingMediatorFromJson(json);
  const ColumnStrategySettingMediator._();

  ColumnStrategyEnum get strategy => switch (current) {
        ColumnStrategyEnumType.fixedCount =>
          ColumnStrategyEnum.fixedCount(fixedCount),
        ColumnStrategyEnumType.maxExtent =>
          ColumnStrategyEnum.maxExtent(maxExtent),
        ColumnStrategyEnumType.minExtent =>
          ColumnStrategyEnum.minExtent(minExtent),
      };
}
