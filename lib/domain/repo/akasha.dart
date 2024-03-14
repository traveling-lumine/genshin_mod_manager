import 'dart:typed_data';

import 'package:genshin_mod_manager/domain/entity/akasha.dart';

abstract interface class NahidaliveAPI {
  Future<List<NahidaliveElement>> fetchNahidaliveElements();

  Future<NahidaliveElement> fetchNahidaliveElement(final String uuid);

  Future<NahidaliveDownloadElement> downloadUrl(final String uuid,
      {final String? pw, final String? updateCode,});

  Future<Uint8List> download(final NahidaliveDownloadElement downloadElement);
}
