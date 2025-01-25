import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../l1/api/nahida.dart';
import '../impl/nahida.dart';

part 'nahida_api.g.dart';

@riverpod
NahidaAPI nahidaApi(final Ref ref) {
  final dio = Dio()
    ..options.validateStatus = (final status) => (status ?? 0) < 500;
  return NahidaAPIImpl(dio);
}
