import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/domain/entity/akasha.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/akasha.dart';
import 'package:genshin_mod_manager/domain/usecase/akasha_download.dart';
import 'package:genshin_mod_manager/domain/usecase/akasha_refresh.dart';
import 'package:genshin_mod_manager/ui/service/folder_observer_service.dart';
import 'package:genshin_mod_manager/ui/util/mod_writer.dart';

abstract interface class NahidaStoreViewModel extends ChangeNotifier {
  Future<List<NahidaliveElement>> get elements;

  void onRefresh();

  Future<void> onModDownload({
    required NahidaliveElement element,
    required ModCategory category,
    String? pw,
  });

  void registerDownloadCallbacks({
    Future<String?> Function()? onPasswordRequired,
    void Function(HttpException e)? onApiException,
    void Function(NahidaliveElement element)? onDownloadComplete,
    void Function(ModCategory category, String modName, Uint8List data)?
        onExtractFail,
  });
}

NahidaStoreViewModel createViewModel({
  required NahidaliveAPI api,
  required RecursiveObserverService observer,
}) {
  return _NahidaStoreViewModelImpl(
    api: api,
    observer: observer,
  );
}

final class _NahidaStoreViewModelImpl extends ChangeNotifier
    implements NahidaStoreViewModel {
  final NahidaliveAPI _api;
  final RecursiveObserverService _observer;

  Future<String?> Function()? _onPasswordRequired;
  void Function(HttpException)? _onApiException;
  void Function(NahidaliveElement)? _onDownloadComplete;
  void Function(ModCategory, String, Uint8List)? _onExtractFail;

  Future<List<NahidaliveElement>> _elements;

  @override
  Future<List<NahidaliveElement>> get elements => _elements;

  set elements(Future<List<NahidaliveElement>> value) {
    _elements = value;
    notifyListeners();
  }

  _NahidaStoreViewModelImpl(
      {required NahidaliveAPI api, required RecursiveObserverService observer})
      : _api = api,
        _observer = observer,
        _elements = api.fetchNahidaliveElements();

  @override
  void onRefresh() {
    elements = AkashaRefreshUseCase(api: _api).call();
  }

  @override
  Future<void> onModDownload({
    required NahidaliveElement element,
    required ModCategory category,
    String? pw,
  }) async {
    try {
      await AkashaDownloadUseCase(
        api: _api,
        element: element,
        category: category,
        pw: pw,
      ).call();
    } on HttpException catch (e) {
      _onApiException?.call(e);
      return;
    } on WrongPasswordException {
      final password = await _onPasswordRequired?.call();
      if (password == null) return;
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
    _observer.forceUpdate();
  }

  @override
  void registerDownloadCallbacks({
    Future<String?> Function()? onPasswordRequired,
    void Function(HttpException e)? onApiException,
    void Function(NahidaliveElement element)? onDownloadComplete,
    void Function(ModCategory category, String modName, Uint8List data)?
        onExtractFail,
  }) {
    _onPasswordRequired = onPasswordRequired;
    _onApiException = onApiException;
    _onDownloadComplete = onDownloadComplete;
    _onExtractFail = onExtractFail;
  }
}
