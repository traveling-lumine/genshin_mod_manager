// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryWatcherHash() => r'ecaf2695fc727e030c873b84a35f9aac1c63c632';

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

/// See also [categoryWatcher].
@ProviderFor(categoryWatcher)
const categoryWatcherProvider = CategoryWatcherFamily();

/// See also [categoryWatcher].
class CategoryWatcherFamily extends Family<AsyncValue<List<Mod>>> {
  /// See also [categoryWatcher].
  const CategoryWatcherFamily();

  /// See also [categoryWatcher].
  CategoryWatcherProvider call(
    ModCategory category,
  ) {
    return CategoryWatcherProvider(
      category,
    );
  }

  @override
  CategoryWatcherProvider getProviderOverride(
    covariant CategoryWatcherProvider provider,
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
  String? get name => r'categoryWatcherProvider';
}

/// See also [categoryWatcher].
class CategoryWatcherProvider extends AutoDisposeStreamProvider<List<Mod>> {
  /// See also [categoryWatcher].
  CategoryWatcherProvider(
    ModCategory category,
  ) : this._internal(
          (ref) => categoryWatcher(
            ref as CategoryWatcherRef,
            category,
          ),
          from: categoryWatcherProvider,
          name: r'categoryWatcherProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryWatcherHash,
          dependencies: CategoryWatcherFamily._dependencies,
          allTransitiveDependencies:
              CategoryWatcherFamily._allTransitiveDependencies,
          category: category,
        );

  CategoryWatcherProvider._internal(
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
  Override overrideWith(
    Stream<List<Mod>> Function(CategoryWatcherRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoryWatcherProvider._internal(
        (ref) => create(ref as CategoryWatcherRef),
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
  AutoDisposeStreamProviderElement<List<Mod>> createElement() {
    return _CategoryWatcherProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryWatcherProvider && other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CategoryWatcherRef on AutoDisposeStreamProviderRef<List<Mod>> {
  /// The parameter `category` of this provider.
  ModCategory get category;
}

class _CategoryWatcherProviderElement
    extends AutoDisposeStreamProviderElement<List<Mod>>
    with CategoryWatcherRef {
  _CategoryWatcherProviderElement(super.provider);

  @override
  ModCategory get category => (origin as CategoryWatcherProvider).category;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
