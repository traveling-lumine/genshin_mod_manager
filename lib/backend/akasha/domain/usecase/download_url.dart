import '../../../mod_writer/domain/mod_writer.dart';
import '../entity/akasha.dart';
import '../repo/akasha.dart';

final class AkashaDownloadUrlUseCase {
  const AkashaDownloadUrlUseCase({
    required this.api,
    required this.element,
    required this.writer,
    this.pw,
  });

  final NahidaliveAPI api;
  final NahidaliveElement element;
  final ModWriter writer;
  final String? pw;

  Future<void> call() async {
    final url = await api.downloadUrl(element.uuid, pw: pw); // HttpException
    if (!url.success) {
      throw const WrongPasswordException();
    }
    final data = await api.download(url);
    await writer(
      modName: element.title,
      data: data,
    ); // ModZipExtractionException
  }
}

/// The exception thrown when the password is wrong.
class WrongPasswordException implements Exception {
  /// Creates a new instance.
  const WrongPasswordException();
}
