import 'package:dio/dio.dart';

import '../../../filesystem/l0/api/filesystem.dart';
import '../../../filesystem/l0/entity/mod_category.dart';
import '../api/nahida_repo.dart';
import '../api/stream.dart';
import '../entity/download_state.dart';
import '../entity/nahida_element.dart';
import '../entity/wrong_password.dart';

Future<void> downloadUrlUseCase({
  required final NahidaRepository repo,
  required final NahidaDownloadStatusQueue downloadQueue,
  required final NahidaliveElement element,
  required final ModCategory category,
  required final String turnstile,
  required final Filesystem fs,
  final String? pw,
}) async {
  if (element.password && pw == null) {
    downloadQueue
        .add(NahidaDownloadState.wrongPassword(element: element, wrongPw: pw));
    return;
  }

  try {
    final responseData =
        await repo.addDownload(element: element, turnstile: turnstile, pw: pw);

    await fs.importZipFile(category, element.title, responseData);
  } on DioException catch (e) {
    switch (e.error) {
      case WrongPasswordException _:
        downloadQueue.add(
          NahidaDownloadState.wrongPassword(element: element, wrongPw: pw),
        );
        return;
    }
  }
  downloadQueue.add(NahidaDownloadState.completed(element: element));
}
