// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gamesListHash() => r'34ef463bc1f4436d8734d241004024a1068fd2ff';

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
String _$targetGameHash() => r'13e6eec75fd42814f6e5d333323426288c7088cc';

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
String _$cardColorHash() => r'ee0b08b2f417baa2fbb91b853291ff40f890b809';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$CardColor extends BuildlessAutoDisposeNotifier<Color> {
  late final bool isBright;
  late final bool isEnabled;

  Color build({
    required bool isBright,
    required bool isEnabled,
  });
}

/// See also [CardColor].
@ProviderFor(CardColor)
const cardColorProvider = CardColorFamily();

/// See also [CardColor].
class CardColorFamily extends Family<Color> {
  /// See also [CardColor].
  const CardColorFamily();

  /// See also [CardColor].
  CardColorProvider call({
    required bool isBright,
    required bool isEnabled,
  }) {
    return CardColorProvider(
      isBright: isBright,
      isEnabled: isEnabled,
    );
  }

  @override
  CardColorProvider getProviderOverride(
    covariant CardColorProvider provider,
  ) {
    return call(
      isBright: provider.isBright,
      isEnabled: provider.isEnabled,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cardColorProvider';
}

/// See also [CardColor].
class CardColorProvider
    extends AutoDisposeNotifierProviderImpl<CardColor, Color> {
  /// See also [CardColor].
  CardColorProvider({
    required bool isBright,
    required bool isEnabled,
  }) : this._internal(
          () => CardColor()
            ..isBright = isBright
            ..isEnabled = isEnabled,
          from: cardColorProvider,
          name: r'cardColorProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$cardColorHash,
          dependencies: CardColorFamily._dependencies,
          allTransitiveDependencies: CardColorFamily._allTransitiveDependencies,
          isBright: isBright,
          isEnabled: isEnabled,
        );

  CardColorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.isBright,
    required this.isEnabled,
  }) : super.internal();

  final bool isBright;
  final bool isEnabled;

  @override
  Color runNotifierBuild(
    covariant CardColor notifier,
  ) {
    return notifier.build(
      isBright: isBright,
      isEnabled: isEnabled,
    );
  }

  @override
  Override overrideWith(CardColor Function() create) {
    return ProviderOverride(
      origin: this,
      override: CardColorProvider._internal(
        () => create()
          ..isBright = isBright
          ..isEnabled = isEnabled,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        isBright: isBright,
        isEnabled: isEnabled,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<CardColor, Color> createElement() {
    return _CardColorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CardColorProvider &&
        other.isBright == isBright &&
        other.isEnabled == isEnabled;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, isBright.hashCode);
    hash = _SystemHash.combine(hash, isEnabled.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CardColorRef on AutoDisposeNotifierProviderRef<Color> {
  /// The parameter `isBright` of this provider.
  bool get isBright;

  /// The parameter `isEnabled` of this provider.
  bool get isEnabled;
}

class _CardColorProviderElement
    extends AutoDisposeNotifierProviderElement<CardColor, Color>
    with CardColorRef {
  _CardColorProviderElement(super.provider);

  @override
  bool get isBright => (origin as CardColorProvider).isBright;
  @override
  bool get isEnabled => (origin as CardColorProvider).isEnabled;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
