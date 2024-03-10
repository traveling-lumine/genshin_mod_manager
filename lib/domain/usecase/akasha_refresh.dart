import 'package:genshin_mod_manager/domain/entity/akasha.dart';
import 'package:genshin_mod_manager/domain/repo/akasha.dart';

final class AkashaRefreshUseCase {
  final NahidaliveAPI _api;

  AkashaRefreshUseCase({required NahidaliveAPI api}) : _api = api;

  Future<List<NahidaliveElement>> call() {
    return _api.fetchNahidaliveElements();
  }
}
