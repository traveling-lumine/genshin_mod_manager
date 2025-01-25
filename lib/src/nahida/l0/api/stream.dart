import '../entity/download_state.dart';

abstract interface class NahidaDownloadStatusQueue {
  void add(final NahidaDownloadState event);
}
