import 'package:genshin_mod_manager/domain/entity/akasha.dart';
import 'package:genshin_mod_manager/domain/repo/akasha.dart';

final class AkashaRefreshUseCase {

  AkashaRefreshUseCase({required final NahidaliveAPI api}) : _api = api;
  final NahidaliveAPI _api;

  Future<List<NahidaliveElement>> call() => _api.fetchNahidaliveElements();
}
