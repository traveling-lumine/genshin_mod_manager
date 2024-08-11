// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ini_widget.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$iniLinesHash() => r'f5b401c6dc2a479ae9679d1f64face6587eeb0cd';

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

abstract class _$IniLines
    extends BuildlessAutoDisposeStreamNotifier<List<String>> {
  late final IniFile iniFile;

  Stream<List<String>> build(
    IniFile iniFile,
  );
}

/// See also [IniLines].
@ProviderFor(IniLines)
const iniLinesProvider = IniLinesFamily();

/// See also [IniLines].
class IniLinesFamily extends Family<AsyncValue<List<String>>> {
  /// See also [IniLines].
  const IniLinesFamily();

  /// See also [IniLines].
  IniLinesProvider call(
    IniFile iniFile,
  ) {
    return IniLinesProvider(
      iniFile,
    );
  }

  @override
  IniLinesProvider getProviderOverride(
    covariant IniLinesProvider provider,
  ) {
    return call(
      provider.iniFile,
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
  String? get name => r'iniLinesProvider';
}

/// See also [IniLines].
class IniLinesProvider
    extends AutoDisposeStreamNotifierProviderImpl<IniLines, List<String>> {
  /// See also [IniLines].
  IniLinesProvider(
    IniFile iniFile,
  ) : this._internal(
          () => IniLines()..iniFile = iniFile,
          from: iniLinesProvider,
          name: r'iniLinesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$iniLinesHash,
          dependencies: IniLinesFamily._dependencies,
          allTransitiveDependencies: IniLinesFamily._allTransitiveDependencies,
          iniFile: iniFile,
        );

  IniLinesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.iniFile,
  }) : super.internal();

  final IniFile iniFile;

  @override
  Stream<List<String>> runNotifierBuild(
    covariant IniLines notifier,
  ) {
    return notifier.build(
      iniFile,
    );
  }

  @override
  Override overrideWith(IniLines Function() create) {
    return ProviderOverride(
      origin: this,
      override: IniLinesProvider._internal(
        () => create()..iniFile = iniFile,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        iniFile: iniFile,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<IniLines, List<String>>
      createElement() {
    return _IniLinesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IniLinesProvider && other.iniFile == iniFile;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, iniFile.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IniLinesRef on AutoDisposeStreamNotifierProviderRef<List<String>> {
  /// The parameter `iniFile` of this provider.
  IniFile get iniFile;
}

class _IniLinesProviderElement
    extends AutoDisposeStreamNotifierProviderElement<IniLines, List<String>>
    with IniLinesRef {
  _IniLinesProviderElement(super.provider);

  @override
  IniFile get iniFile => (origin as IniLinesProvider).iniFile;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
