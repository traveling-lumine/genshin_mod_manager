import 'package:dio/dio.dart';

import '../../../filesystem/l0/entity/mod_category.dart';
import '../../../mod_writer/l1/mod_writer.dart';
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

    await createModWriter(categoryPath: category.path)(
      modName: element.title,
      data: responseData,
    );
  } on DioException catch (e) {
    switch (e.error) {
      case WrongPasswordException _:
        downloadQueue.add(
          NahidaDownloadState.wrongPassword(element: element, wrongPw: pw),
        );
        return;
    }
  } on ModZipExtractionException catch (e) {
    downloadQueue.add(
      NahidaDownloadState.modZipExtractionException(
        element: element,
        category: category,
        data: e.data,
      ),
    );
    return;
  }
  downloadQueue.add(NahidaDownloadState.completed(element: element));
}
