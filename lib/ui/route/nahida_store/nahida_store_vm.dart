import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/data/repo/akasha.dart';
import 'package:genshin_mod_manager/data/repo/mod_writer.dart';
import 'package:genshin_mod_manager/domain/entity/akasha.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/akasha.dart';
import 'package:genshin_mod_manager/domain/repo/filesystem_watcher.dart';
import 'package:genshin_mod_manager/domain/usecase/akasha/download_url.dart';
import 'package:genshin_mod_manager/domain/usecase/akasha/refresh.dart';
import 'package:genshin_mod_manager/ui/viewmodel_base.dart';

abstract interface class NahidaStoreViewModel implements BaseViewModel {
  Future<List<NahidaliveElement>> get elements;

  void onRefresh();

  Future<void> onModDownload({
    required final NahidaliveElement element,
    required final ModCategory category,
    final String? pw,
  });

  void registerDownloadCallbacks({
    final Future<String?> Function()? onPasswordRequired,
    final void Function(HttpException e)? onApiException,
    final void Function(NahidaliveElement element)? onDownloadComplete,
    final void Function(ModCategory category, String modName, Uint8List data)?
        onExtractFail,
  });
}

NahidaStoreViewModel createViewModel({
  required final RecursiveFileSystemWatcher observer,
}) =>
    _NahidaStoreViewModelImpl(
      observer: observer,
    );

final class _NahidaStoreViewModelImpl extends ChangeNotifier
    implements NahidaStoreViewModel {
  _NahidaStoreViewModelImpl({
    required this.observer,
  }) : api = createNahidaliveAPI() {
    onRefresh();
  }

  final NahidaliveAPI api;
  final RecursiveFileSystemWatcher observer;

  Future<String?> Function()? _onPasswordRequired;
  void Function(HttpException)? _onApiException;
  void Function(NahidaliveElement)? _onDownloadComplete;
  void Function(ModCategory, String, Uint8List)? _onExtractFail;

  @override
  Future<List<NahidaliveElement>> get elements => _elements;
  late Future<List<NahidaliveElement>> _elements;

  set elements(final Future<List<NahidaliveElement>> value) {
    _elements = value;
    notifyListeners();
  }

  @override
  void onRefresh() {
    // ignore: discarded_futures
    elements = AkashaRefreshUseCase(api: api).call();
  }

  @override
  Future<void> onModDownload({
    required final NahidaliveElement element,
    required final ModCategory category,
    final String? pw,
  }) async {
    final writer = createModWriter(category: category);
    try {
      await AkashaDownloadUrlUseCase(
        api: api,
        element: element,
        writer: writer,
        pw: pw,
      ).call();
    } on HttpException catch (e) {
      _onApiException?.call(e);
      return;
    } on WrongPasswordException {
      final password = await _onPasswordRequired?.call();
      if (password == null) {
        return;
      }
      return onModDownload(
        element: element,
        category: category,
        pw: password,
      );
    } on ModZipExtractionException catch (e) {
      _onExtractFail?.call(category, element.title, e.data);
      return;
    }
    _onDownloadComplete?.call(element);
    observer.forceUpdate();
  }

  @override
  void registerDownloadCallbacks({
    final Future<String?> Function()? onPasswordRequired,
    final void Function(HttpException e)? onApiException,
    final void Function(NahidaliveElement element)? onDownloadComplete,
    final void Function(ModCategory category, String modName, Uint8List data)?
        onExtractFail,
  }) {
    _onPasswordRequired = onPasswordRequired;
    _onApiException = onApiException;
    _onDownloadComplete = onDownloadComplete;
    _onExtractFail = onExtractFail;
  }
}
