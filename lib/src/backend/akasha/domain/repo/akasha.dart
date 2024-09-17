import 'dart:typed_data';

import '../entity/nahida_element.dart';

/// An API to interact with Nahidalive.
abstract interface class NahidaliveAPI {
  /// Fetches all Nahidalive elements.
  Future<List<NahidaliveElement>> fetchNahidaliveElements(final int pageNum);

  /// Fetches a single Nahidalive element.
  Future<NahidaliveElement> fetchNahidaliveElement(final String uuid);

  /// Fetches the download URL for a Nahidalive element.
  Future<Uint8List> downloadUuid({
    required final String uuid,
    final String? pw,
  });
}
