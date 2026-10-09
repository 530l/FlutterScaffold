import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterscaffold/app.dart';
import 'package:flutterscaffold/core/widget/state_views.dart';
import 'package:flutterscaffold/features/home/model/banner.dart';
import 'package:flutterscaffold/features/home/provider/home_banner_provider.dart';
import 'package:flutterscaffold/features/home/repository/home_repository.dart';

/// 固定返回预设数据。
class _FakeHomeRepository extends HomeRepository {
  _FakeHomeRepository([this._banners = const <BannerModel>[]]) : super(Dio());

  final List<BannerModel> _banners;

  @override
  Future<List<BannerModel>> getBanners({CancelToken? cancelToken}) async =>
      _banners;
}

/// 记录请求次数,验证页面重进后的查询。
class _MutableHomeRepository extends HomeRepository {
  _MutableHomeRepository() : super(Dio());

  List<BannerModel> banners = const [];

  int callCount = 0;

  @override
  Future<List<BannerModel>> getBanners({CancelToken? cancelToken}) async {
    callCount++;
    return banners;
  }
}

/// 使用独立作用域和假仓库。
Widget _testApp(HomeRepository repository) => ProviderScope(
  overrides: [homeRepositoryProvider.overrideWithValue(repository)],
  child: const App(),
);

void main() {
  testWidgets('应用启动冒烟测试:渲染出 MaterialApp 与首页空态', (tester) async {
    await tester.pumpWidget(_testApp(_FakeHomeRepository()));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('探索'), findsNWidgets(2));
    expect(find.byType(EmptyView), findsOneWidget);
    expect(find.text('暂无数据'), findsOneWidget);
  });

  testWidgets('首页数据就绪时正确渲染列表', (tester) async {
    const banners = [
      BannerModel(id: 1, title: '测试轮播', imagePath: 'https://example.com/1.png'),
    ];
    await tester.pumpWidget(_testApp(_FakeHomeRepository(banners)));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('测试轮播'), findsOneWidget);
  });

  testWidgets('重进首页会重新请求:同一容器内重新挂载 App 后展示新数据', (tester) async {
    final fakeRepository = _MutableHomeRepository();
    final container = ProviderContainer(
      overrides: [homeRepositoryProvider.overrideWithValue(fakeRepository)],
    );
    addTearDown(container.dispose);
    Widget buildApp() =>
        UncontrolledProviderScope(container: container, child: const App());

    fakeRepository.banners = const [
      BannerModel(id: 1, title: '轮播一', imagePath: 'https://example.com/1.png'),
    ];
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('轮播一'), findsOneWidget);
    final callsAfterFirstVisit = fakeRepository.callCount;
    expect(callsAfterFirstVisit, greaterThan(0));

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    fakeRepository.banners = const [
      BannerModel(id: 2, title: '轮播二', imagePath: 'https://example.com/2.png'),
    ];

    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(fakeRepository.callCount, greaterThan(callsAfterFirstVisit));
    expect(find.text('轮播二'), findsOneWidget);
    expect(find.text('轮播一'), findsNothing);
  });

  testWidgets('底部 tab 切换与详情页传值回值', (tester) async {
    await tester.pumpWidget(_testApp(_FakeHomeRepository()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('创作'), findsOneWidget);

    await tester.tap(find.text('创作'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('创作'), findsNWidgets(2));
    expect(find.text('打开详情'), findsOneWidget);

    await tester.tap(find.text('打开详情'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('详情'), findsOneWidget);
    expect(find.text('收到参数:'), findsOneWidget);
    expect(find.text('创作'), findsOneWidget);

    await tester.tap(find.text('返回一个值'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('详情页返回: 我是从详情页带回的值'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('打开详情'), findsOneWidget);
    expect(find.text('收到参数:'), findsNothing);
  });
}
