import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/backend/akasha/data/repo/akasha.dart';
import 'package:genshin_mod_manager/src/backend/akasha/domain/entity/nahida_element.dart';

void main() {
  late NahidaliveAPIImpl api;
  setUp(() {
    api = NahidaliveAPIImpl();
  });
  group(
    'Fetch page',
    () {
      test(
        'Fetch page',
        () async {
          final result = await api.fetchNahidaliveElements(1);
          expect(result, isA<List<NahidaliveElement>>());
        },
      );
      test(
        'Fetch page 0 should throw',
        () async {
          expect(
            () async => api.fetchNahidaliveElements(0),
            throwsArgumentError,
          );
        },
      );
    },
  );
  test(
    'Fetch single',
    () async {
      final result = await api.fetchNahidaliveElements(1);
      expect(result, isNotEmpty);
      final singleUuid = result.first.uuid;
      final singleResult = await api.fetchNahidaliveElement(singleUuid);
      expect(singleResult, isA<NahidaliveElement>());
      expect(singleResult.uuid, equals(result.first.uuid));
    },
  );
}
