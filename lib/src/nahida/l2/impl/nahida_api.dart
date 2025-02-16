import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../l0/entity/download_element.dart';
import '../../l1/api/nahida_api.dart';
import '../../l1/entity/nahida_page_result.dart';
import '../../l1/entity/nahida_single_fetch_result.dart';

part 'nahida_api.g.dart';

@RestApi(baseUrl: 'https://nahida.live')
abstract class NahidaAPIImpl implements NahidaAPI {
  factory NahidaAPIImpl(
    final Dio dio, {
    final String? baseUrl,
    final ParseErrorLogger? errorLogger,
  }) = _NahidaAPIImpl;

  @override
  @POST('/api/gimme/{uuid}')
  @FormUrlEncoded()
  Future<NahidaDownloadUrlElement> getDownloadLink({
    @Path('uuid') required final String uuid,
    @Field('cftoken') required final String turnstile,
    @Field('password') final String? pw,
  });

  @override
  @GET('/api/hello/{uuid}')
  Future<NahidaSingleFetchResult> getNahidaElement({
    @Path('uuid') required final String uuid,
  });

  @override
  @GET('/api/hello/mods')
  Future<NahidaPageQueryResult> getNahidaElementPage({
    @Query('p') required final int pageNum,
    @Header('Authorization') required final String authKey,
    @Query('ps') final int pageSize = 100,
  });
}
