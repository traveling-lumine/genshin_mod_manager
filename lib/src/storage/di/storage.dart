import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repo/null_storage.dart';
import '../data/repo/sharedpreference_storage.dart';
import '../domain/repo/persistent_storage.dart' as s;
import '../domain/usecase/shared_storage.dart';

part 'storage.g.dart';

@riverpod
class PersistentStorage extends _$PersistentStorage {
  static const _timeout = Duration(seconds: 5);

  @override
  Future<s.PersistentStorage> build() async {
    final sharedPreferenceStorage = SharedPreferenceStorage(
      await SharedPreferences.getInstance().timeout(_timeout),
    );
    afterInitializationUseCase(sharedPreferenceStorage);
    return sharedPreferenceStorage;
  }

  void useNullStorage() {
    if (state.hasValue) {
      return;
    }
    state = AsyncValue.data(NullSharedPreferenceStorage());
  }
}
