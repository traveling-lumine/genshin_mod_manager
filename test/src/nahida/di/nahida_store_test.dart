import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/nahida/di/nahida_store.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  test('nahida Api', () {
    final container = ProviderContainer();
    final api = container.read(nahidaApiProvider);
    expect(api, isNotNull);
  });
}
