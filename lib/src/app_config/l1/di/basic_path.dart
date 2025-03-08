import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../l0/api/basic_path.dart';
import '../impl/basic_path.dart';

part 'basic_path.g.dart';

@riverpod
BasicPathProvider basicPath(final Ref ref) => BasicPathProviderImpl();
