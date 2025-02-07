import '../entity/nahida_page_result.dart';
import '../entity/nahida_single_fetch_result.dart';
import '../../l0/entity/download_element.dart';

abstract interface class NahidaAPI {
  Future<NahidaSingleFetchResult> getNahidaElement({
    required final String uuid,
  });

  Future<NahidaPageQueryResult> getNahidaElementPage({
    required final int pageNum,
    required final String authKey,
    final int pageSize = 100,
  });

  Future<NahidaDownloadUrlElement> getDownloadLink({
    required final String uuid,
    required final String turnstile,
    final String? pw,
  });
}
