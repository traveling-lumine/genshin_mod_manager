import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../l0/api/app_config_facade.dart';
import '../impl/app_config_facade.dart';
import 'app_config.dart';

part 'app_config_facade.g.dart';

@riverpod
AppConfigFacade appConfigFacade(final Ref ref) {
  final watch = ref.watch(appConfigCProvider);
  return AppConfigFacadeImpl(currentConfig: watch.valueOrNull);
}
