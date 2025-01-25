import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_mod_manager/src/nahida/l0/di/nahida_download_queue.dart';
import 'package:genshin_mod_manager/src/nahida/l0/entity/download_state.dart';
import 'package:genshin_mod_manager/src/nahida/l0/entity/nahida_element.dart';
import 'package:genshin_mod_manager/src/nahida/l1/di/nahida_repo.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  test('nahida download queue', () async {
    final container = ProviderContainer();
    final notifier = container.read(nahidaRepositoryProvider);
    final listener = container.listen(
      nahidaDownloadQueueProvider,
      (final previous, final next) {
        expect(next, isA<AsyncData<NahidaDownloadState>>());
        final nextVal = (next as AsyncData<NahidaDownloadState>).value;
        expect(nextVal, isA<NahidaDownloadStateWrongPassword>());
      },
    );
    expect(notifier, isNotNull);
    const element = NahidaliveElement(
      uuid: '',
      version: '',
      title: '',
      tags: [],
      previewUrl: '',
      password: true,
    );
    await notifier.addDownload(
      element: element,
      turnstile: '',
    );
    listener.close();
  });
}
