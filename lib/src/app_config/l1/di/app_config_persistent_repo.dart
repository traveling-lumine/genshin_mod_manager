import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../l0/api/app_config_persistent_repo.dart';
import '../impl/app_config_persistent_repo.dart';

part 'app_config_persistent_repo.g.dart';

@riverpod
AppConfigPersistentRepo appConfigPersistentRepo(final Ref ref) =>
    AppConfigPersistentRepoImpl();
