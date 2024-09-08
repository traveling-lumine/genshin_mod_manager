import '../../../mod_writer/domain/mod_writer.dart';
import '../entity/nahida_element.dart';
import '../entity/wrong_password.dart';
import '../repo/akasha.dart';

Future<void> akashaDownloadUrlUseCase({
  required final NahidaliveAPI api,
  required final NahidaliveElement element,
  required final ModWriter writer,
  final String? pw,
}) async {
  final url = await api.downloadUrl(element.uuid, pw: pw); // HttpException
  if (!url.success) {
    throw const WrongPasswordException();
  }
  final data = await api.download(url);
  await writer(
    modName: element.title.trim(),
    data: data,
  ); // ModZipExtractionException
}
