import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../l0/constants.dart';
import 'storage.dart';
import 'value_settable.dart';

part 'run_together.g.dart';

final runTogetherKey = StorageAccessKey.runTogether.name;
const runTogetherDefault = false;

@riverpod
class RunTogether extends _$RunTogether implements ValueSettable<bool> {
  @override
  bool build() {
    final watch = ref.watch(persistentRepoProvider).valueOrNull;
    return watch?.getBool(runTogetherKey) ?? runTogetherDefault;
  }

  @override
  void setValue(final bool value) {
    final read = ref.read(persistentRepoProvider).valueOrNull;
    read?.setBool(runTogetherKey, value);
    state = value;
  }
}
