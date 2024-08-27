import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../backend/storage/data/repo/sharedpreference_storage.dart';
import '../backend/storage/domain/repo/persistent_storage.dart';
import '../backend/storage/domain/usecase/shared_storage.dart';

part 'storage.g.dart';

/// The shared preference.
@riverpod
Future<SharedPreferences> sharedPreference(
  final SharedPreferenceRef ref,
) =>
    SharedPreferences.getInstance().timeout(const Duration(seconds: 5));

/// The storage for the shared preference.
@riverpod
PersistentStorage persistentStorage(
  final PersistentStorageRef ref,
) {
  final sharedPreferences =
      ref.watch(sharedPreferenceProvider).unwrapPrevious().valueOrNull;
  if (sharedPreferences == null) {
    return NullSharedPreferenceStorage();
  }
  final sharedPreferenceStorage = SharedPreferenceStorage(sharedPreferences);
  afterInitializationUseCase(sharedPreferenceStorage);
  return sharedPreferenceStorage;
}
