// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage.dart';

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
    r'510e9cefc899c22ef5b729c06db71aa75742dd0c';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
