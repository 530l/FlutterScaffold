import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterscaffold/app.dart';
import 'package:flutterscaffold/core/widget/state_views.dart';
import 'package:flutterscaffold/features/home/model/banner.dart';
import 'package:flutterscaffold/features/home/provider/home_banner_provider.dart';
import 'package:flutterscaffold/features/home/repository/home_repository.dart';

/// 假仓库:返回预设列表,避免测试里发真实网络请求
class _FakeHomeRepository extends HomeRepository {
  _FakeHomeRepository([this._banners = const <BannerModel>[]]) : super(Dio());

  final List<BannerModel> _banners;

  @override
  Future<List<BannerModel>> getBanners({CancelToken? cancelToken}) async =>
      _banners;
}

/// 可变假仓库:数据可中途替换,并统计请求次数(用于验证重进首页的刷新行为)
class _MutableHomeRepository extends HomeRepository {
  _MutableHomeRepository() : super(Dio());

  /// 当前预设数据
  List<BannerModel> banners = const [];

  /// getBanners 被调用次数
  int callCount = 0;

  @override
  Future<List<BannerModel>> getBanners({CancelToken? cancelToken}) async {
    callCount++;
    return banners;
  }
}

void main() {
  testWidgets('应用启动冒烟测试:渲染出 MaterialApp 与首页空态', (tester) async {
    // 顶层信号是全局单例,测试间会串扰:
    // 先把仓库换成假实现,再 reset 回到初始态(reset 会立即用假仓库重新求值)
    final realRepository = homeRepository;
    homeRepository = _FakeHomeRepository();
    addTearDown(() => homeRepository = realRepository);
    homeBanner.reset();

    await tester.pumpWidget(const App());

    // 先出一帧加载态,再让 futureSignal 的请求完成
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MaterialApp), findsOneWidget);
    // 首 tab(探索)正常渲染:AppBar 标题与底部 tab 文案各一处
    expect(find.text('探索'), findsNWidgets(2));
    // 空列表展示 EmptyView 占位
    expect(find.byType(EmptyView), findsOneWidget);
    expect(find.text('暂无数据'), findsOneWidget);
  });

  testWidgets('首页数据就绪时正确渲染列表', (tester) async {
    const banners = [
      BannerModel(id: 1, title: '测试轮播', imagePath: 'https://example.com/1.png'),
    ];
    final realRepository = homeRepository;
    homeRepository = _FakeHomeRepository(banners);
    addTearDown(() => homeRepository = realRepository);
    homeBanner.reset();

    await tester.pumpWidget(const App());

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('测试轮播'), findsOneWidget);
  });

  testWidgets('重进首页会重新请求:重新挂载 App 后展示新数据(对齐 autoDispose 行为)', (tester) async {
    // 场景:登出离开首页 → 数据源已变化 → 重新进入首页
    // 信号全局常驻不销毁,重进必须由 HomeScreen initState 主动刷新,否则永远展示旧缓存
    final realRepository = homeRepository;
    final fakeRepository = _MutableHomeRepository();
    homeRepository = fakeRepository;
    addTearDown(() => homeRepository = realRepository);

    // 注意:reset 内部会立即用当前仓库数据重新求值,必须先备好数据再 reset
    fakeRepository.banners = const [
      BannerModel(id: 1, title: '轮播一', imagePath: 'https://example.com/1.png'),
    ];
    homeBanner.reset();

    // 第一次进入首页:展示「轮播一」
    await tester.pumpWidget(const App());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('轮播一'), findsOneWidget);
    final callsAfterFirstVisit = fakeRepository.callCount;
    expect(callsAfterFirstVisit, greaterThan(0));

    // 卸载 App(模拟登出离开首页),期间数据源换成「轮播二」
    await tester.pumpWidget(const SizedBox());
    fakeRepository.banners = const [
      BannerModel(id: 2, title: '轮播二', imagePath: 'https://example.com/2.png'),
    ];

    // 重新进入首页:注意这里不能 reset,信号仍持有旧缓存
    // 期望 initState 触发 refresh 再发请求,界面更新为新数据
    await tester.pumpWidget(const App());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(fakeRepository.callCount, greaterThan(callsAfterFirstVisit));
    expect(find.text('轮播二'), findsOneWidget);
    expect(find.text('轮播一'), findsNothing);
  });

  testWidgets('底部 tab 切换与详情页传值回值', (tester) async {
    final realRepository = homeRepository;
    homeRepository = _FakeHomeRepository();
    addTearDown(() => homeRepository = realRepository);
    homeBanner.reset();

    await tester.pumpWidget(const App());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // 初始在「探索」tab:「创作」仅命中底部 tab 文案
    // (IndexedStack 未选中项对 finder 不可见,不会与 tab 文案混淆)
    expect(find.text('创作'), findsOneWidget);

    // 切到「创作」tab
    await tester.tap(find.text('创作'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // 创作页出现:AppBar 标题与 tab 文案各一处
    expect(find.text('创作'), findsNWidgets(2));
    expect(find.text('打开详情'), findsOneWidget);

    // 进入详情页
    await tester.tap(find.text('打开详情'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // 详情页展示传入的 title(壳页在路由下层,不被 finder 计入)
    expect(find.text('详情'), findsOneWidget);
    expect(find.text('收到参数:'), findsOneWidget);
    expect(find.text('创作'), findsOneWidget);

    // 带值返回,pop 回创作页
    await tester.tap(find.text('返回一个值'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // 断言「回值」链路:pop 带出的值经 await push 接住,由 AppToast 展示出来
    expect(find.text('详情页返回: 我是从详情页带回的值'), findsOneWidget);
    // 冲掉 AppToast(smart_dialog 默认展示 2s + 淡出动画),避免遗留 pending timer
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // 回到创作页:详情页内容消失
    expect(find.text('打开详情'), findsOneWidget);
    expect(find.text('收到参数:'), findsNothing);
  });
}
