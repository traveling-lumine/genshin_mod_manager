import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../l0/entity/app_config.dart';
import 'app_config_persistent_repo.dart';

part 'app_config.g.dart';

@riverpod
class AppConfigC extends _$AppConfigC {
  @override
  AppConfig? build() {
    final appConfig = ref.watch(appConfigPersistentRepoProvider);
    final subscription = appConfig.stream.listen((final config) {
      state = AppConfig.fromJson(config);
    });
    ref.onDispose(subscription.cancel);
    return null;
  }

  void update(final AppConfig appConfig) {
    state = appConfig;
  }
}
