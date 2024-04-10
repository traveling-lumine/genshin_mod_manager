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
String _$appStateNotifierHash() => r'b6eaceb6d3f1ba47d1c549fd922abda62b0c0412';

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
String _$darkModeHash() => r'1281ddeac883b0c2bbbb64fe2d2c6660a51febfa';

/// The notifier for the dark mode.
///
/// Copied from [DarkMode].
@ProviderFor(DarkMode)
final darkModeProvider = AutoDisposeNotifierProvider<DarkMode, bool>.internal(
  DarkMode.new,
  name: r'darkModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$darkModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DarkMode = AutoDisposeNotifier<bool>;
String _$enabledFirstHash() => r'b096b02e69b8a05c4be254510a0f16780b1a72cf';

/// The notifier for the enabled first.
///
/// Copied from [EnabledFirst].
@ProviderFor(EnabledFirst)
final enabledFirstProvider =
    AutoDisposeNotifierProvider<EnabledFirst, bool>.internal(
  EnabledFirst.new,
  name: r'enabledFirstProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$enabledFirstHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$EnabledFirst = AutoDisposeNotifier<bool>;
String _$folderIconHash() => r'9af289a05a40d1ae11f88cf8d4599d15d5d6c97b';

/// The notifier for the folder icon.
///
/// Copied from [FolderIcon].
@ProviderFor(FolderIcon)
final folderIconProvider =
    AutoDisposeNotifierProvider<FolderIcon, bool>.internal(
  FolderIcon.new,
  name: r'folderIconProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$folderIconHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FolderIcon = AutoDisposeNotifier<bool>;
String _$moveOnDragHash() => r'766ec13afb52cf5effef5d8382761e824257bd9a';

/// The notifier for the move on drag.
///
/// Copied from [MoveOnDrag].
@ProviderFor(MoveOnDrag)
final moveOnDragProvider =
    AutoDisposeNotifierProvider<MoveOnDrag, bool>.internal(
  MoveOnDrag.new,
  name: r'moveOnDragProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$moveOnDragHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MoveOnDrag = AutoDisposeNotifier<bool>;
String _$runTogetherHash() => r'dc385bbb0d7bb93591373dafbe0c16e13c2d0788';

/// The notifier for the run together.
///
/// Copied from [RunTogether].
@ProviderFor(RunTogether)
final runTogetherProvider =
    AutoDisposeNotifierProvider<RunTogether, bool>.internal(
  RunTogether.new,
  name: r'runTogetherProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$runTogetherHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RunTogether = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
