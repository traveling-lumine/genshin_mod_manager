// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nahida_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$akashaApiHash() => r'cd2b762166d25ea38aa41550bf24fcb2ef0b57b7';

/// See also [akashaApi].
@ProviderFor(akashaApi)
final akashaApiProvider = Provider<NahidaliveAPI>.internal(
  akashaApi,
  name: r'akashaApiProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$akashaApiHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AkashaApiRef = ProviderRef<NahidaliveAPI>;
String _$downloadModelHash() => r'a77b1d9d9d77035b67cbe3edf0a58cca8f20f2f7';

/// See also [downloadModel].
@ProviderFor(downloadModel)
final downloadModelProvider = Provider<NahidaDownloadModel>.internal(
  downloadModel,
  name: r'downloadModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$downloadModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DownloadModelRef = ProviderRef<NahidaDownloadModel>;
String _$akashaElementHash() => r'7cde6d876d5f1d62857b0bd9b566964f75886428';

/// See also [AkashaElement].
@ProviderFor(AkashaElement)
final akashaElementProvider = AutoDisposeAsyncNotifierProvider<AkashaElement,
    List<NahidaliveElement>>.internal(
  AkashaElement.new,
  name: r'akashaElementProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$akashaElementHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AkashaElement = AutoDisposeAsyncNotifier<List<NahidaliveElement>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
