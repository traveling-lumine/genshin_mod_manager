import 'package:genshin_mod_manager/domain/entity/akasha.dart';
import 'package:genshin_mod_manager/domain/entity/mod_category.dart';
import 'package:genshin_mod_manager/domain/repo/akasha.dart';
import 'package:genshin_mod_manager/ui/util/mod_writer.dart';

final class AkashaDownloadUseCase {
  final NahidaliveAPI _api;
  final NahidaliveElement _element;
  final ModCategory _category;
  final String? _pw;

  AkashaDownloadUseCase({
    required NahidaliveAPI api,
    required NahidaliveElement element,
    required ModCategory category,
    String? pw,
  })  : _api = api,
        _element = element,
        _category = category,
        _pw = pw;

  Future<void> call() async {
    final url = await _api.downloadUrl(_element.uuid, pw: _pw); // HttpException
    if (!url.status) throw const WrongPasswordException();
    final data = await _api.download(url);
    await writeModToCategory(
      category: _category,
      modName: _element.title,
      data: data,
    ); // ModZipExtractionException
  }
}

class WrongPasswordException implements Exception {
  const WrongPasswordException();
}
