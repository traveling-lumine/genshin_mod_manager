import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../l0/constants.dart';
import 'storage.dart';
import 'value_settable.dart';

part 'display_enabled_mods_first.g.dart';

final showEnabledModsFirstKey = StorageAccessKey.showEnabledModsFirst.name;
const showEnabledModsFirstDefault = false;

@riverpod
class DisplayEnabledModsFirst extends _$DisplayEnabledModsFirst
    implements ValueSettable<bool> {
  @override
  bool build() {
    final watch = ref.watch(persistentStorageProvider).valueOrNull;
    return watch?.getBool(showEnabledModsFirstKey) ??
        showEnabledModsFirstDefault;
  }

  @override
  void setValue(final bool value) {
    final read = ref.read(persistentStorageProvider).valueOrNull;
    read?.setBool(showEnabledModsFirstKey, value);
    state = value;
  }
}
