import 'package:freezed_annotation/freezed_annotation.dart';

part 'column_strategy.freezed.dart';

@freezed
sealed class ColumnStrategyEnum with _$ColumnStrategyEnum {
  const factory ColumnStrategyEnum.fixedCount(final int numChildren) =
      ColumnStrategyFixedCount;

  const factory ColumnStrategyEnum.maxExtent(final int extent) =
      ColumnStrategyMaxExtent;

  const factory ColumnStrategyEnum.minExtent(final int extent) =
      ColumnStrategyMinExtent;
}
