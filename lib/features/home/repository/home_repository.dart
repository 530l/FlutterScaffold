import 'package:dio/dio.dart';

import '../../../core/network/app_dio_client.dart';
import '../../../core/utils/result.dart';
import '../model/banner.dart';
import 'home_api.dart';

/// 首页数据仓库:统一经 [resultGuard] 包装,UI 层只拿到 [Result],不感知异常
class HomeRepository {
  /// 统一构造:注入全局 Dio 实例
  const HomeRepository(this._dio);

  /// 全局 Dio 实例(已装配鉴权 / 解包 / 日志拦截器)
  final Dio _dio;

  /// 拉取首页轮播列表
  ///
  /// 响应壳已被 EnvelopeInterceptor 解包,这里拿到的直接是纯 data;
  /// [cancelToken] 用于页面销毁时取消在途请求
  Future<Result<List<BannerModel>>> getBanners({CancelToken? cancelToken}) =>
      resultGuard(() => HomeApi(_dio).getBanners(cancelToken));
}
