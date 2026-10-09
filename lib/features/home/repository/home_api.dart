import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

import '../model/banner.dart';

part 'home_api.g.dart';

/// 首页接口。
@RestApi()
abstract class HomeApi {
  factory HomeApi(Dio dio, {String? baseUrl}) = _HomeApi;

  @GET('/banner/json')
  Future<List<BannerModel>> getBanners(
    @CancelRequest() CancelToken? cancelToken,
  );
}
