import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:genshin_mod_manager/domain/entity/akasha.dart';
import 'package:genshin_mod_manager/domain/entity/category.dart';
import 'package:genshin_mod_manager/domain/repo/akasha.dart';
import 'package:genshin_mod_manager/domain/usecase/akasha_download.dart';
import 'package:genshin_mod_manager/domain/usecase/akasha_refresh.dart';
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

NahidaStoreViewModel getViewModel({required NahidaliveAPI api}) {
  return _NahidaStoreViewModelImpl(api: api);
}

final class _NahidaStoreViewModelImpl extends ChangeNotifier
    implements NahidaStoreViewModel {
  final NahidaliveAPI _api;

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

  _NahidaStoreViewModelImpl({required NahidaliveAPI api})
      : _api = api,
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
      _onDownloadComplete?.call(element);
    } on HttpException catch (e) {
      _onApiException?.call(e);
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
    }
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
