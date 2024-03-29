// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferenceHash() => r'7c0ff0611471ae80ca3abfa6f6dd0e9495adcec3';

/// See also [sharedPreference].
@ProviderFor(sharedPreference)
final sharedPreferenceProvider =
    AutoDisposeFutureProvider<SharedPreferences>.internal(
  sharedPreference,
  name: r'sharedPreferenceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferenceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SharedPreferenceRef = AutoDisposeFutureProviderRef<SharedPreferences>;
String _$sharedPreferenceStorageHash() =>
    r'87b1f4a3c3e07e078f8caae22137d1b618944c86';

/// See also [sharedPreferenceStorage].
@ProviderFor(sharedPreferenceStorage)
final sharedPreferenceStorageProvider =
    AutoDisposeProvider<PersistentStorage>.internal(
  sharedPreferenceStorage,
  name: r'sharedPreferenceStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferenceStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SharedPreferenceStorageRef = AutoDisposeProviderRef<PersistentStorage>;
String _$appStateStorageHash() => r'8a88f855a6de6d5238c00e5473844fb4b1865173';

/// See also [appStateStorage].
@ProviderFor(appStateStorage)
final appStateStorageProvider = AutoDisposeProvider<AppStateStorage>.internal(
  appStateStorage,
  name: r'appStateStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appStateStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AppStateStorageRef = AutoDisposeProviderRef<AppStateStorage>;
String _$appStateNotifierHash() => r'4cbe8f907538c5de9f87f5fa7a89d5ae200b1ae3';

/// See also [AppStateNotifier].
@ProviderFor(AppStateNotifier)
final appStateNotifierProvider =
    AutoDisposeNotifierProvider<AppStateNotifier, AppState>.internal(
  AppStateNotifier.new,
  name: r'appStateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appStateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppStateNotifier = AutoDisposeNotifier<AppState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
