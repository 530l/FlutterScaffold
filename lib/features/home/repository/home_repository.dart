import 'package:dio/dio.dart';

import '../../../core/network/api_call.dart';
import '../model/banner.dart';
import 'home_api.dart';

/// 首页查询仓库,通过构造函数注入客户端。
class HomeRepository {
  const HomeRepository(this._dio);

  final Dio _dio;

  Future<List<BannerModel>> getBanners({CancelToken? cancelToken}) =>
      apiCall(() => HomeApi(_dio).getBanners(cancelToken));
}
