// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fs_watcher.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$folderFileWatcherHash() => r'83121e36f7b90b480fe6d23f88e4ee8568db8a46';

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

/// See also [folderFileWatcher].
@ProviderFor(folderFileWatcher)
const folderFileWatcherProvider = FolderFileWatcherFamily();

/// See also [folderFileWatcher].
class FolderFileWatcherFamily extends Family<FolderWatcher<File>> {
  /// See also [folderFileWatcher].
  const FolderFileWatcherFamily();

  /// See also [folderFileWatcher].
  FolderFileWatcherProvider call(
    String path,
    bool watchModifications,
  ) {
    return FolderFileWatcherProvider(
      path,
      watchModifications,
    );
  }

  @override
  FolderFileWatcherProvider getProviderOverride(
    covariant FolderFileWatcherProvider provider,
  ) {
    return call(
      provider.path,
      provider.watchModifications,
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
  String? get name => r'folderFileWatcherProvider';
}

/// See also [folderFileWatcher].
class FolderFileWatcherProvider
    extends AutoDisposeProvider<FolderWatcher<File>> {
  /// See also [folderFileWatcher].
  FolderFileWatcherProvider(
    String path,
    bool watchModifications,
  ) : this._internal(
          (ref) => folderFileWatcher(
            ref as FolderFileWatcherRef,
            path,
            watchModifications,
          ),
          from: folderFileWatcherProvider,
          name: r'folderFileWatcherProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$folderFileWatcherHash,
          dependencies: FolderFileWatcherFamily._dependencies,
          allTransitiveDependencies:
              FolderFileWatcherFamily._allTransitiveDependencies,
          path: path,
          watchModifications: watchModifications,
        );

  FolderFileWatcherProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.path,
    required this.watchModifications,
  }) : super.internal();

  final String path;
  final bool watchModifications;

  @override
  Override overrideWith(
    FolderWatcher<File> Function(FolderFileWatcherRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FolderFileWatcherProvider._internal(
        (ref) => create(ref as FolderFileWatcherRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        path: path,
        watchModifications: watchModifications,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<FolderWatcher<File>> createElement() {
    return _FolderFileWatcherProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FolderFileWatcherProvider &&
        other.path == path &&
        other.watchModifications == watchModifications;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, path.hashCode);
    hash = _SystemHash.combine(hash, watchModifications.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FolderFileWatcherRef on AutoDisposeProviderRef<FolderWatcher<File>> {
  /// The parameter `path` of this provider.
  String get path;

  /// The parameter `watchModifications` of this provider.
  bool get watchModifications;
}

class _FolderFileWatcherProviderElement
    extends AutoDisposeProviderElement<FolderWatcher<File>>
    with FolderFileWatcherRef {
  _FolderFileWatcherProviderElement(super.provider);

  @override
  String get path => (origin as FolderFileWatcherProvider).path;
  @override
  bool get watchModifications =>
      (origin as FolderFileWatcherProvider).watchModifications;
}

String _$fileWatcherHash() => r'e4f2afc91315e3aa2d91d8e440146daf9f30d33f';

/// See also [fileWatcher].
@ProviderFor(fileWatcher)
const fileWatcherProvider = FileWatcherFamily();

/// See also [fileWatcher].
class FileWatcherFamily extends Family<AsyncValue<int>> {
  /// See also [fileWatcher].
  const FileWatcherFamily();

  /// See also [fileWatcher].
  FileWatcherProvider call(
    String path,
  ) {
    return FileWatcherProvider(
      path,
    );
  }

  @override
  FileWatcherProvider getProviderOverride(
    covariant FileWatcherProvider provider,
  ) {
    return call(
      provider.path,
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
  String? get name => r'fileWatcherProvider';
}

/// See also [fileWatcher].
class FileWatcherProvider extends AutoDisposeStreamProvider<int> {
  /// See also [fileWatcher].
  FileWatcherProvider(
    String path,
  ) : this._internal(
          (ref) => fileWatcher(
            ref as FileWatcherRef,
            path,
          ),
          from: fileWatcherProvider,
          name: r'fileWatcherProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fileWatcherHash,
          dependencies: FileWatcherFamily._dependencies,
          allTransitiveDependencies:
              FileWatcherFamily._allTransitiveDependencies,
          path: path,
        );

  FileWatcherProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.path,
  }) : super.internal();

  final String path;

  @override
  Override overrideWith(
    Stream<int> Function(FileWatcherRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FileWatcherProvider._internal(
        (ref) => create(ref as FileWatcherRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        path: path,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<int> createElement() {
    return _FileWatcherProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FileWatcherProvider && other.path == path;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, path.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FileWatcherRef on AutoDisposeStreamProviderRef<int> {
  /// The parameter `path` of this provider.
  String get path;
}

class _FileWatcherProviderElement extends AutoDisposeStreamProviderElement<int>
    with FileWatcherRef {
  _FileWatcherProviderElement(super.provider);

  @override
  String get path => (origin as FileWatcherProvider).path;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
