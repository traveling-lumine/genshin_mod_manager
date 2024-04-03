// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mod_card.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$configPathHash() => r'ac24a243904badc8ed836757b19667a3df0d7692';

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

/// See also [configPath].
@ProviderFor(configPath)
const configPathProvider = ConfigPathFamily();

/// See also [configPath].
class ConfigPathFamily extends Family<AsyncValue<String?>> {
  /// See also [configPath].
  const ConfigPathFamily();

  /// See also [configPath].
  ConfigPathProvider call(
    Mod mod,
  ) {
    return ConfigPathProvider(
      mod,
    );
  }

  @override
  ConfigPathProvider getProviderOverride(
    covariant ConfigPathProvider provider,
  ) {
    return call(
      provider.mod,
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
  String? get name => r'configPathProvider';
}

/// See also [configPath].
class ConfigPathProvider extends AutoDisposeStreamProvider<String?> {
  /// See also [configPath].
  ConfigPathProvider(
    Mod mod,
  ) : this._internal(
          (ref) => configPath(
            ref as ConfigPathRef,
            mod,
          ),
          from: configPathProvider,
          name: r'configPathProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$configPathHash,
          dependencies: ConfigPathFamily._dependencies,
          allTransitiveDependencies:
              ConfigPathFamily._allTransitiveDependencies,
          mod: mod,
        );

  ConfigPathProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mod,
  }) : super.internal();

  final Mod mod;

  @override
  Override overrideWith(
    Stream<String?> Function(ConfigPathRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConfigPathProvider._internal(
        (ref) => create(ref as ConfigPathRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mod: mod,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<String?> createElement() {
    return _ConfigPathProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConfigPathProvider && other.mod == mod;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mod.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ConfigPathRef on AutoDisposeStreamProviderRef<String?> {
  /// The parameter `mod` of this provider.
  Mod get mod;
}

class _ConfigPathProviderElement
    extends AutoDisposeStreamProviderElement<String?> with ConfigPathRef {
  _ConfigPathProviderElement(super.provider);

  @override
  Mod get mod => (origin as ConfigPathProvider).mod;
}

String _$previewHash() => r'c5fdc45be47dd2f3eae7b1001b3d03eb0a1b5443';

/// See also [preview].
@ProviderFor(preview)
const previewProvider = PreviewFamily();

/// See also [preview].
class PreviewFamily extends Family<AsyncValue<Future<FileImage>?>> {
  /// See also [preview].
  const PreviewFamily();

  /// See also [preview].
  PreviewProvider call(
    Mod mod,
  ) {
    return PreviewProvider(
      mod,
    );
  }

  @override
  PreviewProvider getProviderOverride(
    covariant PreviewProvider provider,
  ) {
    return call(
      provider.mod,
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
  String? get name => r'previewProvider';
}

/// See also [preview].
class PreviewProvider extends AutoDisposeStreamProvider<Future<FileImage>?> {
  /// See also [preview].
  PreviewProvider(
    Mod mod,
  ) : this._internal(
          (ref) => preview(
            ref as PreviewRef,
            mod,
          ),
          from: previewProvider,
          name: r'previewProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$previewHash,
          dependencies: PreviewFamily._dependencies,
          allTransitiveDependencies: PreviewFamily._allTransitiveDependencies,
          mod: mod,
        );

  PreviewProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mod,
  }) : super.internal();

  final Mod mod;

  @override
  Override overrideWith(
    Stream<Future<FileImage>?> Function(PreviewRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PreviewProvider._internal(
        (ref) => create(ref as PreviewRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mod: mod,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Future<FileImage>?> createElement() {
    return _PreviewProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PreviewProvider && other.mod == mod;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mod.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PreviewRef on AutoDisposeStreamProviderRef<Future<FileImage>?> {
  /// The parameter `mod` of this provider.
  Mod get mod;
}

class _PreviewProviderElement
    extends AutoDisposeStreamProviderElement<Future<FileImage>?>
    with PreviewRef {
  _PreviewProviderElement(super.provider);

  @override
  Mod get mod => (origin as PreviewProvider).mod;
}

String _$iniPathsHash() => r'e45978e2641edcb1efefc0af9e40e97f26b2608f';

/// See also [iniPaths].
@ProviderFor(iniPaths)
const iniPathsProvider = IniPathsFamily();

/// See also [iniPaths].
class IniPathsFamily extends Family<AsyncValue<List<String>>> {
  /// See also [iniPaths].
  const IniPathsFamily();

  /// See also [iniPaths].
  IniPathsProvider call(
    Mod mod,
  ) {
    return IniPathsProvider(
      mod,
    );
  }

  @override
  IniPathsProvider getProviderOverride(
    covariant IniPathsProvider provider,
  ) {
    return call(
      provider.mod,
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
  String? get name => r'iniPathsProvider';
}

/// See also [iniPaths].
class IniPathsProvider extends AutoDisposeStreamProvider<List<String>> {
  /// See also [iniPaths].
  IniPathsProvider(
    Mod mod,
  ) : this._internal(
          (ref) => iniPaths(
            ref as IniPathsRef,
            mod,
          ),
          from: iniPathsProvider,
          name: r'iniPathsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$iniPathsHash,
          dependencies: IniPathsFamily._dependencies,
          allTransitiveDependencies: IniPathsFamily._allTransitiveDependencies,
          mod: mod,
        );

  IniPathsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mod,
  }) : super.internal();

  final Mod mod;

  @override
  Override overrideWith(
    Stream<List<String>> Function(IniPathsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IniPathsProvider._internal(
        (ref) => create(ref as IniPathsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mod: mod,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<String>> createElement() {
    return _IniPathsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IniPathsProvider && other.mod == mod;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mod.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IniPathsRef on AutoDisposeStreamProviderRef<List<String>> {
  /// The parameter `mod` of this provider.
  Mod get mod;
}

class _IniPathsProviderElement
    extends AutoDisposeStreamProviderElement<List<String>> with IniPathsRef {
  _IniPathsProviderElement(super.provider);

  @override
  Mod get mod => (origin as IniPathsProvider).mod;
}

String _$modCardVMHash() => r'80a1854fbe8fbba9e4b192b11ac035a6a58c54fd';

abstract class _$ModCardVM extends BuildlessAutoDisposeNotifier<ModCardModel> {
  late final Mod mod;

  ModCardModel build(
    Mod mod,
  );
}

/// See also [ModCardVM].
@ProviderFor(ModCardVM)
const modCardVMProvider = ModCardVMFamily();

/// See also [ModCardVM].
class ModCardVMFamily extends Family<ModCardModel> {
  /// See also [ModCardVM].
  const ModCardVMFamily();

  /// See also [ModCardVM].
  ModCardVMProvider call(
    Mod mod,
  ) {
    return ModCardVMProvider(
      mod,
    );
  }

  @override
  ModCardVMProvider getProviderOverride(
    covariant ModCardVMProvider provider,
  ) {
    return call(
      provider.mod,
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
  String? get name => r'modCardVMProvider';
}

/// See also [ModCardVM].
class ModCardVMProvider
    extends AutoDisposeNotifierProviderImpl<ModCardVM, ModCardModel> {
  /// See also [ModCardVM].
  ModCardVMProvider(
    Mod mod,
  ) : this._internal(
          () => ModCardVM()..mod = mod,
          from: modCardVMProvider,
          name: r'modCardVMProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$modCardVMHash,
          dependencies: ModCardVMFamily._dependencies,
          allTransitiveDependencies: ModCardVMFamily._allTransitiveDependencies,
          mod: mod,
        );

  ModCardVMProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mod,
  }) : super.internal();

  final Mod mod;

  @override
  ModCardModel runNotifierBuild(
    covariant ModCardVM notifier,
  ) {
    return notifier.build(
      mod,
    );
  }

  @override
  Override overrideWith(ModCardVM Function() create) {
    return ProviderOverride(
      origin: this,
      override: ModCardVMProvider._internal(
        () => create()..mod = mod,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mod: mod,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<ModCardVM, ModCardModel> createElement() {
    return _ModCardVMProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ModCardVMProvider && other.mod == mod;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mod.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ModCardVMRef on AutoDisposeNotifierProviderRef<ModCardModel> {
  /// The parameter `mod` of this provider.
  Mod get mod;
}

class _ModCardVMProviderElement
    extends AutoDisposeNotifierProviderElement<ModCardVM, ModCardModel>
    with ModCardVMRef {
  _ModCardVMProviderElement(super.provider);

  @override
  Mod get mod => (origin as ModCardVMProvider).mod;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
