import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../l0/api/mod_toggler.dart';
import '../impl/mod_toggler.dart';

part 'mod_toggler.g.dart';

@riverpod
ModToggler modToggler(final Ref ref) => ModTogglerImpl();
