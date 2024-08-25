import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../backend/storage/domain/usecase/paimon_icon.dart';
import '../storage.dart';
import 'value_settable.dart';

part 'use_paimon.g.dart';

@riverpod
class PaimonIcon extends _$PaimonIcon implements ValueSettable<bool> {
  @override
  bool build() {
    final watch = ref.watch(sharedPreferenceStorageProvider);
    return initializePaimonIconUseCase(watch);
  }

  @override
  void setValue(final bool value) {
    final read = ref.read(sharedPreferenceStorageProvider);
    setPaimonIconUseCase(read, value);
    state = value;
  }
}
