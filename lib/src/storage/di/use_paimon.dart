import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../l0/constants.dart';
import 'storage.dart';
import 'value_settable.dart';

part 'use_paimon.g.dart';

final showPaimonIconKey = StorageAccessKey.showPaimonAsEmptyIconFolderIcon.name;
const showPaimonIconDefault = true;

@riverpod
class PaimonIcon extends _$PaimonIcon implements ValueSettable<bool> {
  @override
  bool build() {
    final watch = ref.watch(persistentRepoProvider).valueOrNull;
    return watch?.getBool(showPaimonIconKey) ?? showPaimonIconDefault;
  }

  @override
  void setValue(final bool value) {
    final read = ref.read(persistentRepoProvider).valueOrNull;
    read?.setBool(showPaimonIconKey, value);
    state = value;
  }
}
