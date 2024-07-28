import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'description',
    () {
      final map = {
        'key': {
          'nestedKey': {
            'nestedNestedKey': [1, 2, 3],
          },
        },
      };
      final encoded = jsonEncode(map);
      final decoded = jsonDecode(encoded) as Map;
      final typedMap =
          decoded.cast<String, Map<String, Map<String, List<int>>>>();
      expect(typedMap, isNotNull);
    },
  );
}
