// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preset.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localPresetNotifierHash() =>
    r'8c9e6299666e0ccab8066fa0453f3403031002dd';

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

abstract class _$LocalPresetNotifier
    extends BuildlessAutoDisposeNotifier<List<String>> {
  late final ModCategory category;

  List<String> build(
    ModCategory category,
  );
}

/// See also [LocalPresetNotifier].
@ProviderFor(LocalPresetNotifier)
const localPresetNotifierProvider = LocalPresetNotifierFamily();

/// See also [LocalPresetNotifier].
class LocalPresetNotifierFamily extends Family<List<String>> {
  /// See also [LocalPresetNotifier].
  const LocalPresetNotifierFamily();

  /// See also [LocalPresetNotifier].
  LocalPresetNotifierProvider call(
    ModCategory category,
  ) {
    return LocalPresetNotifierProvider(
      category,
    );
  }

  @override
  LocalPresetNotifierProvider getProviderOverride(
    covariant LocalPresetNotifierProvider provider,
  ) {
    return call(
      provider.category,
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
  String? get name => r'localPresetNotifierProvider';
}

/// See also [LocalPresetNotifier].
class LocalPresetNotifierProvider
    extends AutoDisposeNotifierProviderImpl<LocalPresetNotifier, List<String>> {
  /// See also [LocalPresetNotifier].
  LocalPresetNotifierProvider(
    ModCategory category,
  ) : this._internal(
          () => LocalPresetNotifier()..category = category,
          from: localPresetNotifierProvider,
          name: r'localPresetNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$localPresetNotifierHash,
          dependencies: LocalPresetNotifierFamily._dependencies,
          allTransitiveDependencies:
              LocalPresetNotifierFamily._allTransitiveDependencies,
          category: category,
        );

  LocalPresetNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
  }) : super.internal();

  final ModCategory category;

  @override
  List<String> runNotifierBuild(
    covariant LocalPresetNotifier notifier,
  ) {
    return notifier.build(
      category,
    );
  }

  @override
  Override overrideWith(LocalPresetNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: LocalPresetNotifierProvider._internal(
        () => create()..category = category,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<LocalPresetNotifier, List<String>>
      createElement() {
    return _LocalPresetNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LocalPresetNotifierProvider && other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin LocalPresetNotifierRef on AutoDisposeNotifierProviderRef<List<String>> {
  /// The parameter `category` of this provider.
  ModCategory get category;
}

class _LocalPresetNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<LocalPresetNotifier,
        List<String>> with LocalPresetNotifierRef {
  _LocalPresetNotifierProviderElement(super.provider);

  @override
  ModCategory get category => (origin as LocalPresetNotifierProvider).category;
}

String _$globalPresetNotifierHash() =>
    r'd4a180033236840a9a85efff9fa6df20902931d6';

/// See also [GlobalPresetNotifier].
@ProviderFor(GlobalPresetNotifier)
final globalPresetNotifierProvider =
    AutoDisposeNotifierProvider<GlobalPresetNotifier, List<String>>.internal(
  GlobalPresetNotifier.new,
  name: r'globalPresetNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$globalPresetNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GlobalPresetNotifier = AutoDisposeNotifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
