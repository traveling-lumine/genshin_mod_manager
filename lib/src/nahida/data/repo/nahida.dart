import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../domain/entity/download_element.dart';
import '../../domain/entity/nahida_element.dart';
import '../../domain/repo/nahida.dart';
import '../entity/nahida_page_result.dart';

part 'nahida.g.dart';

@RestApi(baseUrl: 'https://nahida.live')
abstract class NahidaliveAPIImpl implements NahidaliveAPI {
  factory NahidaliveAPIImpl(
    final Dio dio, {
    final String? baseUrl,
    final ParseErrorLogger? errorLogger,
  }) = _NahidaliveAPIImpl;

  @override
  @GET('/api/hello/{uuid}')
  Future<NahidaliveElement> fetchNahidaliveElement({
    @Path('uuid') required final String uuid,
  });

  @override
  @GET('/api/hello/mods')
  Future<NahidaPageResult> fetchNahidaliveElements({
    @Query('p') required final int pageNum,
    @Header('Authorization') required final String authKey,
    @Query('ps') final int pageSize = 100,
  });

  @override
  @POST('/api/gimme/{uuid}')
  @FormUrlEncoded()
  Future<NahidaliveDownloadUrlElement> downloadUuid({
    @Path('uuid') required final String uuid,
    @Field('cftoken') required final String turnstile,
    @Field('password') final String? pw,
  });
}
