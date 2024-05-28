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
    r'652f6ab1e6c45e7453bbe9f1069a1b75710c197f';

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
String _$gamesListHash() => r'9730a07df52dbe2e6a6c3e6faa0cf92c16a01067';

/// See also [GamesList].
@ProviderFor(GamesList)
final gamesListProvider =
    AutoDisposeNotifierProvider<GamesList, List<String>>.internal(
  GamesList.new,
  name: r'gamesListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$gamesListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GamesList = AutoDisposeNotifier<List<String>>;
String _$targetGameHash() => r'0f81ef49cf0aa74159fd1f389a321f324e27a8b9';

/// The target game.
///
/// Copied from [TargetGame].
@ProviderFor(TargetGame)
final targetGameProvider =
    AutoDisposeNotifierProvider<TargetGame, String>.internal(
  TargetGame.new,
  name: r'targetGameProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$targetGameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TargetGame = AutoDisposeNotifier<String>;
String _$gameConfigNotifierHash() =>
    r'5c2c03a2f0c150f8a7777099b64f40c3b46b398c';

/// The notifier for the app state.
///
/// Copied from [GameConfigNotifier].
@ProviderFor(GameConfigNotifier)
final gameConfigNotifierProvider =
    AutoDisposeNotifierProvider<GameConfigNotifier, GameConfig>.internal(
  GameConfigNotifier.new,
  name: r'gameConfigNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gameConfigNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GameConfigNotifier = AutoDisposeNotifier<GameConfig>;
String _$darkModeHash() => r'0e53ec369f142ad88d7a4d1fe3551043ee524823';

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
String _$enabledFirstHash() => r'ec48adf2069a75e15b86b32de6d8222a5f6d9e11';

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
String _$folderIconHash() => r'381bef4b13a81a97089ce1a0d9c51f60960d928d';

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
String _$moveOnDragHash() => r'8402407e4848c77d472ee2b767225fe590867f3f';

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
String _$runTogetherHash() => r'127f6350cf1b134f761bb3821962a3cbb88676e2';

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
