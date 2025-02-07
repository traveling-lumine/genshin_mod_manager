import 'dart:typed_data';

import '../entity/nahida_element.dart';

abstract interface class NahidaRepository {
  Future<Uint8List> addDownload({
    required final NahidaliveElement element,
    required final String turnstile,
    final String? pw,
  });

  Future<List<NahidaliveElement>> getNahidaElementPage({
    required final int pageNum,
    final int pageSize = 100,
  });

  Future<NahidaliveElement> getNahidaElement({
    required final String uuid,
  });
}
