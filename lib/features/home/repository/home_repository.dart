import 'package:dio/dio.dart';

import '../../../core/network/app_dio_client.dart';
import '../model/banner.dart';
import 'home_api.dart';

/// 首页数据仓库:提供首页相关数据查询能力
class HomeRepository {
  /// 统一构造:注入全局 Dio 实例
  const HomeRepository(this._dio);

  /// 全局 Dio 实例(已装配鉴权 / 解包 / 日志拦截器)
  final Dio _dio;

  /// 拉取首页轮播列表
  ///
  /// 响应壳已被 EnvelopeInterceptor 解包,这里直接返回纯业务数据;
  /// 网络与业务异常由 [apiCall] 统一映射为 [AppException] 向上抛出,
  /// 交由上层异步状态自然接管。
  /// [cancelToken] 用于页面销毁时取消在途请求。
  Future<List<BannerModel>> getBanners({CancelToken? cancelToken}) =>
      apiCall(() => HomeApi(_dio).getBanners(cancelToken));
}
