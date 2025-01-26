import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../l0/entity/column_strategy.dart';
import '../l0/usecase/column_strategy.dart';
import 'storage.dart';

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
