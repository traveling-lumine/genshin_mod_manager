import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../backend/akasha/data/repo/akasha.dart';
import '../backend/akasha/domain/repo/akasha.dart';

part 'nahida_store.g.dart';

@riverpod
NahidaliveAPI akashaApi(final AkashaApiRef ref) => NahidaliveAPIImpl();
