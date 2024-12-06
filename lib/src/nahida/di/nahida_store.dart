import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repo/nahida.dart';
import '../domain/repo/nahida.dart';

part 'nahida_store.g.dart';

@riverpod
NahidaliveAPI nahidaApi(final NahidaApiRef ref) => NahidaliveAPIImpl();
