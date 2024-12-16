import '../../../mod_writer/domain/mod_writer.dart';
import '../entity/nahida_element.dart';
import '../repo/nahida.dart';

Future<void> nahidaDownloadUrlUseCase({
  required final NahidaliveAPI api,
  required final NahidaliveElement element,
  required final ModWriter writer,
  final String? pw,
}) async {
  final data = await api.downloadUuid(uuid: element.uuid, pw: pw);
  await writer(
    modName: element.title.trim(),
    data: data,
  ); // ModZipExtractionException
}
