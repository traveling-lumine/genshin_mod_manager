import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../backend/nahida/data/repo/nahida.dart';
import '../backend/nahida/domain/repo/nahida.dart';

part 'nahida_store.g.dart';

@riverpod
NahidaliveAPI nahidaApi(final NahidaApiRef ref) => NahidaliveAPIImpl();
