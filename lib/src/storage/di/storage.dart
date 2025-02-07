import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l0/api/persistent_storage.dart' as s;
import '../l0/usecase/shared_storage.dart';
import '../l1/impl/null_storage.dart';
import '../l1/impl/sharedpreference_storage.dart';

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
