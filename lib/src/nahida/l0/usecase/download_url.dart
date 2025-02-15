import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';

import '../../../filesystem/l0/entity/mod_category.dart';
import '../../../filesystem/l1/impl/path_op_string.dart';
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

    final destDirName =
        await getNonCollidingModName(category.path, element.title);
    final destDirPath = category.path.pJoin(destDirName);
    try {
      final archive =
          collapseArchiveFolder(ZipDecoder().decodeBytes(responseData));
      await extractArchiveToDisk(archive, destDirPath);
    } on Exception {
      throw ModZipExtractionException(data: responseData);
    }
  } on DioException catch (e) {
    switch (e.error) {
      case WrongPasswordException _:
        downloadQueue.add(
          NahidaDownloadState.wrongPassword(element: element, wrongPw: pw),
        );
        return;
    }
  } on ModZipExtractionException catch (e) {
    var writeSuccess = false;
    Exception? exception;
    final fileName = sanitizeString('${element.title}.zip');
    try {
      await File(category.path.pJoin(fileName)).writeAsBytes(e.data);
      writeSuccess = true;
    } on Exception catch (e) {
      writeSuccess = false;
      exception = e;
    }
    downloadQueue.add(
      NahidaDownloadState.modZipExtractionException(
        writeSuccess: writeSuccess,
        fileName: fileName,
        exception: exception,
      ),
    );
    return;
  }
  downloadQueue.add(NahidaDownloadState.completed(element: element));
}
