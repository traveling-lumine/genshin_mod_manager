import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repo/nahida.dart';
import '../domain/repo/nahida.dart';

part 'nahida_store.g.dart';

@riverpod
NahidaliveAPI nahidaApi(final Ref ref) {
  final dio = Dio();
  dio.options.validateStatus = (final status) => true;
  dio.interceptors.add(
    InterceptorsWrapper(
      onResponse: (final response, final handler) {
        final data = response.data as Map;
        if (data['success'] as bool) {
          final dataMap = data['data'] ??= data['mod'] ??= data;
          response.data = dataMap;
          return handler.next(response);
        } else {
          throw Exception(data['error']);
        }
      },
    ),
  );
  return NahidaliveAPIImpl(dio);
}
