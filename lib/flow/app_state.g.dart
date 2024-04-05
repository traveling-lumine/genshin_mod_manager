// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferenceHash() => r'7c0ff0611471ae80ca3abfa6f6dd0e9495adcec3';

/// The shared preference.
///
/// Copied from [sharedPreference].
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

/// The storage for the shared preference.
///
/// Copied from [sharedPreferenceStorage].
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
String _$appStateStorageHash() => r'eddd58f04f26a226d58f13134d4dd54b884c0a9c';

/// The storage for the app state.
///
/// Copied from [appStateStorage].
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
String _$targetGameHash() => r'9884f7c559a7105604a616b197c8be43706b963e';

/// The target game.
///
/// Copied from [TargetGame].
@ProviderFor(TargetGame)
final targetGameProvider =
    AutoDisposeNotifierProvider<TargetGame, TargetGames>.internal(
  TargetGame.new,
  name: r'targetGameProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$targetGameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TargetGame = AutoDisposeNotifier<TargetGames>;
String _$appStateNotifierHash() => r'6ac5deb95599e38e0026b0fbbb00354a2a968c59';

/// The notifier for the app state.
///
/// Copied from [AppStateNotifier].
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
