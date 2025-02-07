import '../api/nahida_repo.dart';
import '../entity/nahida_element.dart';

Future<List<NahidaliveElement>> getNahidaElementPageUseCase({
  required final int pageNum,
  required final NahidaRepository repository,
}) =>
    repository.getNahidaElementPage(pageNum: pageNum);
