import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/repo/persistent_storage.dart' as s;
import 'storage.dart';

part 'column_strategy.freezed.dart';
part 'column_strategy.g.dart';

@riverpod
class ColumnStrategy extends _$ColumnStrategy {
  @override
  ColumnStrategyEnum build() {
    final storage = ref.watch(persistentStorageProvider).valueOrNull;
    return initializeColumnStrategyUseCase(storage);
  }

  void setFixedCount(final int numChildren) {
    final storage = ref.read(persistentStorageProvider).valueOrNull;
    setColumnStrategyUseCase(storage, 0, numChildren);
    state = ColumnStrategyEnum.fixedCount(numChildren);
  }

  void setMaxExtent(final int extent) {
    final storage = ref.read(persistentStorageProvider).valueOrNull;
    setColumnStrategyUseCase(storage, 1, extent);
    state = ColumnStrategyEnum.maxExtent(extent);
  }

  void setMinExtent(final int extent) {
    final storage = ref.read(persistentStorageProvider).valueOrNull;
    setColumnStrategyUseCase(storage, 2, extent);
    state = ColumnStrategyEnum.minExtent(extent);
  }
}

@freezed
sealed class ColumnStrategyEnum with _$ColumnStrategyEnum {
  const factory ColumnStrategyEnum.fixedCount(final int numChildren) =
      ColumnStrategyFixedCount;

  const factory ColumnStrategyEnum.maxExtent(final int extent) =
      ColumnStrategyMaxExtent;

  const factory ColumnStrategyEnum.minExtent(final int extent) =
      ColumnStrategyMinExtent;
}

ColumnStrategyEnum initializeColumnStrategyUseCase(
  final s.PersistentStorage? storage,
) {
  if (storage == null) {
    return const ColumnStrategyEnum.minExtent(440);
  }
  final type = storage.getInt('columnStrategyType');
  final value = storage.getInt('columnStrategyValue');
  if (type == null || value == null) {
    return const ColumnStrategyEnum.minExtent(440);
  }
  switch (type) {
    case 0:
      return ColumnStrategyEnum.fixedCount(value);
    case 1:
      return ColumnStrategyEnum.maxExtent(value);
    case 2:
      return ColumnStrategyEnum.minExtent(value);
    default:
      return const ColumnStrategyEnum.minExtent(440);
  }
}

void setColumnStrategyUseCase(
  final s.PersistentStorage? storage,
  final int strategy,
  final int value,
) {
  if (storage == null) {
    return;
  }
  storage
    ..setInt('columnStrategyType', strategy)
    ..setInt('columnStrategyValue', value);
}
