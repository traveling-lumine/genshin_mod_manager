import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../l0/usecase/enabled_first.dart';
import 'storage.dart';
import 'value_settable.dart';

part 'display_enabled_mods_first.g.dart';

/// The notifier for the enabled first.
@riverpod
class DisplayEnabledModsFirst extends _$DisplayEnabledModsFirst
    implements ValueSettable<bool> {
  @override
  bool build() {
    final watch = ref.watch(persistentStorageProvider).valueOrNull;
    final showEnabledModsFirst = initializeEnabledFirstUseCase(watch);
    return showEnabledModsFirst;
  }

  @override
  void setValue(final bool value) {
    final read = ref.read(persistentStorageProvider).valueOrNull;
    setEnabledFirstUseCase(read, value);
    state = value;
  }
}
