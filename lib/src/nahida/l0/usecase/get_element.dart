import '../api/nahida.dart';
import '../entity/nahida_element.dart';

Future<NahidaliveElement> getNahidaElementUseCase({
  required final NahidaRepository repository,
  required final String uuid,
}) =>
    repository.getNahidaElement(uuid: uuid);
