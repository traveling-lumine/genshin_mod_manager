import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../l0/constants.dart';
import 'storage.dart';
import 'value_settable.dart';

part 'dark_mode.g.dart';

final darkModeKey = StorageAccessKey.darkMode.name;
const darkModeDefault = true;

@riverpod
class DarkMode extends _$DarkMode implements ValueSettable<bool> {
  @override
  bool build() {
    final watch = ref.watch(persistentRepoProvider).valueOrNull;
    return watch?.getBool(darkModeKey) ?? darkModeDefault;
  }

  @override
  void setValue(final bool value) {
    final read = ref.read(persistentRepoProvider).valueOrNull;
    read?.setBool(darkModeKey, value);
    state = value;
  }
}
