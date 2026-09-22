import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterscaffold/app.dart';
import 'package:flutterscaffold/core/utils/result.dart';
import 'package:flutterscaffold/features/home/model/banner.dart';
import 'package:flutterscaffold/features/home/provider/home_banner_provider.dart';
import 'package:flutterscaffold/features/home/repository/home_repository.dart';

/// 假仓库:返回空列表,避免测试里发真实网络请求
class _FakeHomeRepository extends HomeRepository {
  _FakeHomeRepository() : super(Dio());

  @override
  Future<Result<List<BannerModel>>> getBanners({CancelToken? cancelToken}) async =>
      Result.success(const <BannerModel>[]);
}

void main() {
  testWidgets('应用启动冒烟测试:渲染出 MaterialApp 与首页空态', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        // 覆盖首页数据仓库,断网环境下也可稳定通过
        overrides: [
          homeRepositoryProvider.overrideWithValue(_FakeHomeRepository()),
        ],
        child: const App(),
      ),
    );

    // 先出一帧骨架,再让异步 provider 完成
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MaterialApp), findsOneWidget);
    // 首页 AppBar 正常渲染
    expect(find.text('首页'), findsOneWidget);
    // 空列表属 data 分支:渲染的是空 ListView(占位视图只在 loading/error 出现)
    expect(find.byType(ListView), findsOneWidget);
  });
}
