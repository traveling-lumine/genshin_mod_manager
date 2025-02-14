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

@freezed
sealed class ColumnStrategyEntryEnum with _$ColumnStrategyEntryEnum {
  const factory ColumnStrategyEntryEnum.fixedCount() =
      ColumnStrategyEntryFixedCount;

  const factory ColumnStrategyEntryEnum.maxExtent() =
      ColumnStrategyEntryMaxExtent;

  const factory ColumnStrategyEntryEnum.minExtent() =
      ColumnStrategyEntryMinExtent;

  factory ColumnStrategyEntryEnum.fromJson(final Map<String, dynamic> json) =>
      _$ColumnStrategyEntryEnumFromJson(json);
}

@freezed
class ColumnStrategySettingMediator with _$ColumnStrategySettingMediator {
  // annotation is valid.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory ColumnStrategySettingMediator({
    required final ColumnStrategyEntryEnum current,
    required final int fixedCount,
    required final int maxExtent,
    required final int minExtent,
  }) = _ColumnStrategySettingMediator;

  factory ColumnStrategySettingMediator.fromJson(
    final Map<String, dynamic> json,
  ) =>
      _$ColumnStrategySettingMediatorFromJson(json);
  const ColumnStrategySettingMediator._();

  ColumnStrategyEnum get strategy => current.when(
        fixedCount: () => ColumnStrategyEnum.fixedCount(fixedCount),
        maxExtent: () => ColumnStrategyEnum.maxExtent(maxExtent),
        minExtent: () => ColumnStrategyEnum.minExtent(minExtent),
      );
}
