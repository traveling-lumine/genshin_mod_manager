import '../../data/entity/nahida_page_result.dart';
import '../entity/download_element.dart';
import '../entity/nahida_element.dart';

abstract interface class NahidaliveAPI {
  Future<NahidaliveElement> fetchNahidaliveElement({
    required final String uuid,
  });

  Future<NahidaPageResult> fetchNahidaliveElements({
    required final int pageNum,
    required final String authKey,
    final int pageSize = 100,
  });

  Future<NahidaliveDownloadUrlElement> downloadUuid({
    required final String uuid,
    required final String turnstile,
    final String? pw,
  });
}
