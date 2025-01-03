import '../constants.dart';
import '../entity/column_strategy.dart';
import '../repo/persistent_storage.dart' as s;

ColumnStrategyEnum initializeColumnStrategyUseCase(
  final s.PersistentStorage? storage,
) {
  if (storage == null) {
    return const ColumnStrategyEnum.minExtent(440);
  }
  final type = storage.getInt(StorageAccessKey.columnStrategyType.name);
  final value = storage.getInt(StorageAccessKey.columnStrategyValue.name);
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
    ..setInt(StorageAccessKey.columnStrategyType.name, strategy)
    ..setInt(StorageAccessKey.columnStrategyValue.name, value);
}
