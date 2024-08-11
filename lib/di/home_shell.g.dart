// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_shell.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$folderIconsHash() => r'c746a9b261566d9ff3967c4192d72eba0b0cc91b';

/// See also [folderIcons].
@ProviderFor(folderIcons)
final folderIconsProvider = AutoDisposeStreamProvider<List<String>>.internal(
  folderIcons,
  name: r'folderIconsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$folderIconsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FolderIconsRef = AutoDisposeStreamProviderRef<List<String>>;
String _$folderIconPathHash() => r'2d1847dacc9ee4db9a2041c268ba0ea93c7859fc';

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

/// See also [folderIconPath].
@ProviderFor(folderIconPath)
const folderIconPathProvider = FolderIconPathFamily();

/// See also [folderIconPath].
class FolderIconPathFamily extends Family<String?> {
  /// See also [folderIconPath].
  const FolderIconPathFamily();

  /// See also [folderIconPath].
  FolderIconPathProvider call(
    String categoryName,
  ) {
    return FolderIconPathProvider(
      categoryName,
    );
  }

  @override
  FolderIconPathProvider getProviderOverride(
    covariant FolderIconPathProvider provider,
  ) {
    return call(
      provider.categoryName,
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
  String? get name => r'folderIconPathProvider';
}

/// See also [folderIconPath].
class FolderIconPathProvider extends AutoDisposeProvider<String?> {
  /// See also [folderIconPath].
  FolderIconPathProvider(
    String categoryName,
  ) : this._internal(
          (ref) => folderIconPath(
            ref as FolderIconPathRef,
            categoryName,
          ),
          from: folderIconPathProvider,
          name: r'folderIconPathProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$folderIconPathHash,
          dependencies: FolderIconPathFamily._dependencies,
          allTransitiveDependencies:
              FolderIconPathFamily._allTransitiveDependencies,
          categoryName: categoryName,
        );

  FolderIconPathProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryName,
  }) : super.internal();

  final String categoryName;

  @override
  Override overrideWith(
    String? Function(FolderIconPathRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FolderIconPathProvider._internal(
        (ref) => create(ref as FolderIconPathRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryName: categoryName,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String?> createElement() {
    return _FolderIconPathProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FolderIconPathProvider &&
        other.categoryName == categoryName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryName.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FolderIconPathRef on AutoDisposeProviderRef<String?> {
  /// The parameter `categoryName` of this provider.
  String get categoryName;
}

class _FolderIconPathProviderElement extends AutoDisposeProviderElement<String?>
    with FolderIconPathRef {
  _FolderIconPathProviderElement(super.provider);

  @override
  String get categoryName => (origin as FolderIconPathProvider).categoryName;
}

String _$homeShellListHash() => r'9498c1c39f421d309c73d0f6e401745870b57195';

/// See also [HomeShellList].
@ProviderFor(HomeShellList)
final homeShellListProvider = AutoDisposeStreamNotifierProvider<HomeShellList,
    List<ModCategory>>.internal(
  HomeShellList.new,
  name: r'homeShellListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeShellListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HomeShellList = AutoDisposeStreamNotifier<List<ModCategory>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
