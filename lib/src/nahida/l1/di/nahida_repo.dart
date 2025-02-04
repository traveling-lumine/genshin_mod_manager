import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../l0/api/nahida.dart';
import '../../l2/di/nahida_api.dart';
import '../impl/nahida.dart';

part 'nahida_repo.g.dart';

@riverpod
NahidaRepository nahidaRepository(final Ref ref) =>
    NahidaRepoImpl(api: ref.watch(nahidaApiProvider));
