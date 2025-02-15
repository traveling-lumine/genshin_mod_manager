import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../l0/entity/app_config.dart';
import 'app_config_persistent_repo.dart';

part 'app_config.g.dart';

@riverpod
class AppConfigC extends _$AppConfigC {
  @override
  Stream<AppConfig> build() {
    final appConfig = ref.watch(appConfigPersistentRepoProvider);
    return appConfig.stream.map(AppConfig.fromJson);
  }

  void setData(final AppConfig appConfig) {
    state = AsyncData(appConfig);
  }
}
