import 'dart:typed_data';

import 'package:genshin_mod_manager/domain/entity/akasha.dart';

abstract interface class NahidaliveAPI {
  Future<List<NahidaliveElement>> fetchNahidaliveElements();

  Future<NahidaliveElement> fetchNahidaliveElement(String uuid);

  Future<NahidaliveDownloadElement> downloadUrl(String uuid,
      {String? pw, String? updateCode});

  Future<Uint8List> download(NahidaliveDownloadElement downloadElement);
}
