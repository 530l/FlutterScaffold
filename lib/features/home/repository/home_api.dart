import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';

import '../model/banner.dart';

part 'home_api.g.dart';

/// 首页相关接口(retrofit 声明式定义,实现由 home_api.g.dart 生成)
@RestApi()
abstract class HomeApi {
  /// 由 build_runner 生成的实现类构造
  factory HomeApi(Dio dio, {String? baseUrl}) = _HomeApi;

  /// 首页轮播列表
  ///
  /// [cancelToken]:可选取消令牌,调用方可在页面销毁时取消在途请求
  @GET('/banner/json')
  Future<List<BannerModel>> getBanners(
    @CancelRequest() CancelToken? cancelToken,
  );
}
