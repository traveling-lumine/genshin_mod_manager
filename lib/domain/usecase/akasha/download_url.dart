import 'package:genshin_mod_manager/domain/entity/akasha.dart';
import 'package:genshin_mod_manager/domain/repo/akasha.dart';
import 'package:genshin_mod_manager/domain/repo/mod_writer.dart';
import 'package:meta/meta.dart';

@immutable
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
    if (!url.status) {
      throw const WrongPasswordException();
    }
    final data = await api.download(url);
    await writer.write(
      modName: element.title,
      data: data,
    ); // ModZipExtractionException
  }
}

/// The exception thrown when the password is wrong.
@immutable
class WrongPasswordException implements Exception {
  /// Creates a new instance.
  const WrongPasswordException();
}
