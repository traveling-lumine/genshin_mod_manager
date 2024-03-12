import 'package:genshin_mod_manager/domain/entity/akasha.dart';
import 'package:genshin_mod_manager/domain/repo/akasha.dart';
import 'package:genshin_mod_manager/domain/repo/mod_writer.dart';

final class AkashaDownloadUseCase {
  final NahidaliveAPI api;
  final NahidaliveElement element;
  final ModWriter writer;
  final String? pw;

  AkashaDownloadUseCase({
    required this.api,
    required this.element,
    required this.writer,
    this.pw,
  });

  Future<void> call() async {
    final url = await api.downloadUrl(element.uuid, pw: pw); // HttpException
    if (!url.status) throw const WrongPasswordException();
    final data = await api.download(url);
    await writer.write(
      modName: element.title,
      data: data,
    ); // ModZipExtractionException
  }
}

class WrongPasswordException implements Exception {
  const WrongPasswordException();
}
