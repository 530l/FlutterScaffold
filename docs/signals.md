# signals 状态管理使用指南(小白版)

> 面向第一次接触状态管理、或刚加入团队的同学。文中所有代码都出自本项目真实文件(标注了路径),照抄即可用。
> 读完你就能独立完成一个新页面的「拿数据 → 展示 → 操作 → 测试」全链路。

---

## 1. 三分钟搞懂:什么是状态管理,signals 在干嘛

**状态**就是「会变的数据」:轮播列表、登录与否、按钮是不是加载中,都是状态。
**页面只是状态的投影**:状态变了,页面跟着变。问题在于——数据变了,怎么通知所有显示它的页面?

没有状态管理时,你得手动 `setState`、一层层传回调。signals 的答案特别简单:

> **signal = 一个「会喊人的盒子」。**

```dart
import 'package:signals/signals.dart';

final counter = signal(0);   // 造一个盒子,里面放 0

counter.value;               // 读盒子里的值 → 0
counter.value = 1;           // 往盒子里写新值 → 所有读过它的页面自动重建
```

- **读**用 `.value`,**写**也用 `.value`。
- 谁在页面 `build` 里**读**过这个盒子,盒子变了就自动通知谁重建——不用注册、不用手动刷新。
- 就这么多。剩下的都是这个思想的延伸。

> **import 提示**:信号本身来自 `package:signals/signals.dart`;而第 3、5 节页面里要用的 `SignalWidget` / `SignalStatefulWidget` / `SignalBuilder` 在 `package:signals_flutter` 里——写页面时导 `import 'package:signals/signals_flutter.dart';`(它同时包含核心 API,项目真实页面文件顶部导的就是它,如 `home_screen.dart`、`login_screen.dart`)。

---

## 2. 本项目的两种固定套路

业务数据无非两类,项目里各有定式,**新页面照抄对应模块即可**:

| 你要做的事 | 例子 | 套路 | 照抄模块 |
|---|---|---|---|
| **查询**:页面拿数据来看 | 轮播列表、搜索结果 | `futureSignal` 一行搞定 | `features/home/` |
| **操作**:用户做一件事 | 登录、提交表单、点赞 | `asyncSignal` + 顶层操作函数 | `features/auth/` |

记不清时问自己:**「这数据是给我看的,还是用户改的?」** 给我看 → futureSignal;用户改 → asyncSignal。

> 还有一类状态**不需要** signals:纯页面内部的 UI 状态。比如主壳页的「当前选中第几个 tab」就是本地 `int + setState`(`features/main/view/main_page.dart`),简单直接。**不是所有状态都值得进信号。**

---

## 3. 套路一:查询(futureSignal)——照抄 home 模块

### 3.1 状态文件(`features/home/provider/home_banner_provider.dart`)

整个文件就这么点,逐行拆解:

```dart
/// 首页仓库实例:widget 测试直接重新赋值为假实现,这是唯一的注入缝
HomeRepository homeRepository = HomeRepository(dioClient);

/// 首页轮播状态:futureSignal 驱动的异步三态(加载中 / 数据 / 错误)
final homeBanner = futureSignal<List<BannerModel>>(
  () => homeRepository.getBanners(),
  options: AsyncSignalOptions(name: 'homeBanner'),
);
```

- `futureSignal(函数)`:把一个「返回 Future 的函数」装进信号。它会自动跑这个函数,并跟踪它的进行中/成功/失败状态。
- **懒求值**:不读不请求。第一次有人在页面里读 `homeBanner.value`,才真正发起网络请求。
- 上面代码里的 `homeRepository` 是个**可变顶层变量**,别嫌它土——它是全项目唯一的「注入缝」:widget 测试直接给它赋一个假仓库,就能让测试不发真实网络请求(见第 6 节 FAQ)。
- `options: AsyncSignalOptions(name: ...)`:给信号起名,开发时日志/DevTools 里好认。注意 signals 7.x 中老的 `debugLabel` 参数已废弃。

### 3.2 状态长什么样:AsyncState 三态

`homeBanner.value` 的类型不是 `List<BannerModel>`,而是一个「状态包装」`AsyncState<List<BannerModel>>`,它有三种基本形态(下表的 `state` 指从 `homeBanner.value` 取出的那个状态对象,比如先 `final state = homeBanner.value;`):

| 形态 | 含义 | 怎么取数据 |
|---|---|---|
| `AsyncLoading` | 请求进行中 | 没有数据,显示加载中 |
| `AsyncData` | 成功 | `state.value` 拿到列表 |
| `AsyncError` | 失败 | `state.error` 拿到异常 |

另外还有 `AsyncDataRefreshing` / `AsyncDataReloading` 等子类——「正在刷新,但手里还留着旧数据」。**你几乎不用直接处理它们**,统一交给 `AsyncView`(下节)。

### 3.3 页面侧:读 `.value` + `AsyncView` 四态渲染

`features/home/view/home_screen.dart` 的核心就两行 + 一个通用组件:

```dart
class HomeScreen extends SignalStatefulWidget {          // 有状态页用它,无状态页用 SignalWidget
  ...
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final bannersAsync = homeBanner.value;                // 读 .value → 本页自动订阅,数据变了自动重建
    Future<void> onRefresh() => homeBanner.refresh();     // 下拉 / 重试统一走信号的 refresh

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: AsyncView<List<BannerModel>>(              // 四态统一交给 AsyncView
          value: bannersAsync,
          onRetry: onRefresh,
          dataBuilder: (banners) => ListView.builder(...), // 只写「有数据」这一种情况!
        ),
      ),
    );
  }
}
```

**你只需要写 `dataBuilder`(数据长什么样)**,加载中/空数据/错误三态由 `core/widget/async_view.dart` 的 `AsyncView` 统一渲染(LoadingView / EmptyView / ErrorView,都支持自定义,详见其构造参数)。

### 3.4 刷新的两种方式

| 方法 | 行为 | 用在哪 |
|---|---|---|
| `homeBanner.refresh()` | **保留旧数据/旧错误**进入刷新态 `AsyncDataRefreshing`(列表不闪,旧内容上转个圈出新的) | 下拉刷新、错误页点「重试」——本项目两者统一走它(`home_screen.dart` 里 `onRetry` 绑的就是 `onRefresh`) |
| `homeBanner.reload()` | 同样**保留旧数据/旧错误**,只是内部状态标记换成 `AsyncDataReloading` | 预留给「查询条件变了」的重新加载,本项目目前没用到 |

两者的实际行为几乎一样:**都不丢旧数据/旧错误**,置 isLoading=true 重发请求;区别只在内部状态类(Refreshing / Reloading)的语义约定——查询条件没变用 refresh、变了用 reload。

> 坑:signals 7.1.0 源码注释说 reload「丢弃一切回到 AsyncLoading」,但它的**真实实现是保留旧值**(源码里就是 `AsyncDataReloading(旧值)`,旧错误同理),注释与实现不符,别被带偏。

### 3.5 一个必须知道的坑:switch 匹配顺序

如果你自己写 switch 处理 `AsyncState`(**通常不需要,AsyncView 已处理**),记住:

```dart
// ✅ 正确:Data / Error 写在前面(state 即上面说的 homeBanner.value 取出的状态对象)
return switch (state) {
  AsyncData(:final value) => 显示数据(value),
  AsyncError(:final error) => 显示错误(error),
  _ => 加载中(),          // AsyncLoading 及其它
};

// ❌ 错误:先匹配 AsyncLoading 会把 Refreshing/Reloading 子类也吞掉,
//    刷新期间页面会「闪回加载态、丢掉旧数据」
```

原因:Refreshing/Reloading 子类**同时是** `AsyncData` **和** `AsyncLoading`,谁写在前面上谁。`core/widget/async_view.dart` 里有同样注释。

---

## 4. 套路二:操作(asyncSignal + 顶层函数)——照抄 auth 模块

「用户做一件事」比查询多两个诉求:**过程可控**(先校验、防重复提交)、**结果要带回给调用方**(成功跳页、失败弹 toast)。所以不用 futureSignal,改用「手动挡」。

### 4.1 状态文件(`features/auth/auth_provider.dart`)

```dart
/// 登录态数据:就是个普通类,不需要任何代码生成
class AuthState {
  const AuthState({this.isLoggedIn = false, this.token});
  final bool isLoggedIn;
  final String? token;
  ...
}

/// 仓库实例(模块私有,不搞注入)
final AuthRepository _authRepository = AuthRepository();

/// 全局登录态信号(手动驱动)
/// AsyncLoading=启动恢复中或登录中;AsyncData=未登录/已登录;AsyncError=登录失败
final authState = asyncSignal<AuthState>(
  const AsyncLoading(),
  options: AsyncSignalOptions(name: 'authState'),
);

/// 登录:成功写入已登录态并原样返回 Result;失败写入错误态并原样返回
Future<Result<String>> login(String username, String password) async {
  // 防重复提交:登录中直接忽略本次调用
  if (authState.value.isLoading) {
    return const Result.failure(BizException('正在处理中,请勿重复提交', code: -1));
  }
  authState.setLoading();                       // ① 置 loading → 按钮自动变「登录中...」并禁用

  final result = await _authRepository.login(username, password);  // ② 干活

  switch (result) {
    case Success(:final value):
      authState.setValue(AuthState(isLoggedIn: true, token: value));  // ③ 写成功态
      return result;
    case Failure(:final error):
      authState.setError(error);                // ③' 写失败态
      Logger.w('登录失败: ${error.message}');
      return result;
  }
}

/// 登出:清 token 回未登录态
Future<void> logout() async {
  await TokenStorage.clearToken();
  authState.setValue(const AuthState());
}
```

要点:

- `asyncSignal(初始值)` 造一个**手动驱动**的异步信号;`setLoading()/setValue(v)/setError(e)` 是三兄弟,写哪个页面就变哪态。
- 注释里的「启动恢复中」:App 启动时 `main()` 会在 runApp 前先调 `restoreAuth()`(也在 `auth_provider.dart` 里),从本地取回 token 恢复登录态,期间保持 loading、避免闪错页面。
- `BizException` 是 `AppException`(`core/network/app_exception.dart`)的业务异常子类——第 7 节说的「异常统一映射为 AppException」,它就是其中一种。
- **顶层函数就是「动作」**,没有 Controller 类、没有 Store 类——这就是 signals 官方推荐的极简风格,项目刻意保持这样(用户要求:不过度设计)。
- 操作函数**返回 `Result<T>`**(成功/失败的可穷举包装,见 `core/utils/result.dart`),页面拿到后 switch 穷举处理,**不在页面里 try/catch**。错误文案统一在 `AppExceptionMapper` 里翻译,页面只管展示 `error.message`。

### 4.2 页面侧(`features/auth/view/login_screen.dart`)

```dart
// build 里读 .value,登录态一变页面自动重建
final loading = authState.value.isLoading;
...
TDButton(
  text: loading ? '登录中...' : '登录',
  disabled: loading,          // loading 时禁用 + 后端防重复,双保险
  onTap: _handleLogin,
);

Future<void> _handleLogin() async {
  final result = await login(_usernameController.text, _passwordController.text);   // 直接调顶层函数
  if (!mounted) return;
  switch (result) {
    case Success():
      AppToast.show('登录成功');
      context.go(RoutePaths.main);
    case Failure(:final error):
      AppToast.error(error.message);         // 统一文案,页面零硬编码
  }
}
```

注意 loading 按钮是「免费」得到的:`login()` 里一句 `setLoading()`,所有读 `authState` 的地方自动跟着变——这就是第 1 节「盒子会喊人」的威力。

---

## 5. 页面订阅:SignalWidget 家族

| 场景 | 用法 |
|---|---|
| 无状态页面 | `class XxxPage extends SignalWidget` |
| 有状态页面(有 controller 等) | `class XxxPage extends SignalStatefulWidget`,其 State 类仍是普通 `State<T>` |
| 普通页面里的局部刷新 | 包一层 `SignalBuilder(builder: (context) => Text('${s.value}'))` |

规则只有一条,但它是**全项目最容易踩的坑**:

> **在 `build` 方法里读 `.value` 才会订阅;在回调/闭包里读,只是读了个值,不会订阅。**

```dart
// ✅ build 里读:counter 变了,本页自动重建
Widget build(BuildContext context) => Text('${counter.value}');

// ❌ 闭包里读:点按钮时取了一次值而已,counter 之后变了页面纹丝不动
onPressed: () => print(counter.value),

// 闭包里要最新值没问题——但别指望它带来刷新;需要刷新就把读取挪回 build
```

另外:**`Watch` 组件已废弃**(signals 7.x),网上老博客/老 AI 回答还在用,别抄。

---

## 6. FAQ 与坑清单

**Q1:widget 测试怎么让信号不发真实网络请求?**
答案就是 3.1 说的「注入缝」+ `reset()`,真实写法(`test/widget_test.dart`):

```dart
testWidgets('...', (tester) async {
  // 顶层信号是全局单例,测试间会串扰:
  // ① 换假仓库(记下真仓库,tearDown 恢复) ② reset 回到初始态,并立即用当前(假)仓库重新求值
  final realRepository = homeRepository;
  homeRepository = _FakeHomeRepository(预设数据);
  addTearDown(() => homeRepository = realRepository);
  homeBanner.reset();

  await tester.pumpWidget(const App());
  await tester.pump(const Duration(milliseconds: 100));   // 让 futureSignal 的请求完成
  ...
});
```

注意:`reset()` 内部会**立即**用当前仓库求值一次,所以要先备好假数据再 reset。

**Q2:为什么我的页面重进后还是旧数据,不重新请求?**
信号全局常驻、缓存跨页面保留,这是特性不是 bug。要「重进必拉新」,照抄 `home_screen.dart` 的 `initState`:

```dart
// 已有数据/错误(非首次进入)时主动 refresh:保留旧数据的同时拉最新
final bannerState = homeBanner.peek();          // peek = 只读值、不订阅(initState 里也没有可订阅的上下文)
if (bannerState is AsyncData || bannerState is AsyncError) {
  homeBanner.refresh();
}
```

注意本项目首页嵌在主壳 `IndexedStack` 里,切 tab 不会重挂载、不走这段逻辑;整壳重建(登出再登录)才会。

**Q3:`debugLabel` 传了报废弃警告?**
signals 7.x 改为 `options: AsyncSignalOptions(name: '...')`。

**Q4:effect/computed 是什么,我该用吗?**
- `computed(() => a.value + b.value)`:由别的信号推导出的信号,纯读场景很好用。
- `effect(() => print(s.value))`:值一变就执行副作用。
本项目目前都没用到——**有真实需要再学**,别为了用而用。切记:在 effect 里写它自己订阅的信号会死循环(cycle 报错)。

**Q5:写过 Riverpod,怎么对应过来?**

| Riverpod 概念 | 本项目对应 |
|---|---|
| `xxxProvider`(Provider/未来 Provider) | 顶层 `final xxx = futureSignal(...)` |
| `AsyncNotifier` + 方法 | `asyncSignal` + 顶层操作函数 |
| `ref.watch(xxx)` | `SignalWidget` 的 build 里读 `xxx.value` |
| `ref.read(xxx.notifier).method()` | 直接调顶层函数 |
| `ProviderScope(overrides:)` 测试替换 | 给可变顶层仓库变量重新赋值 + `reset()` |

**Q6:信号需要销毁吗?**
顶层信号跟随 App 生命周期,常驻即可,项目里没有也不需要 dispose 场景。页面私有的临时信号才涉及销毁,目前项目里没有这种用法。

---

## 7. 新页面接入 checklist(四步)

以「商品列表页」为例,全部照抄现有模块:

1. **模型**:`features/goods/model/goods.dart` —— 复杂模型 `@freezed`,简单状态类手写(参考 `AuthState`)
2. **接口与仓库**:`features/goods/repository/goods_api.dart`(`@RestApi()` 抽象类)+ `goods_repository.dart`:
   - 查询:`apiCall(() => api.fetch())` 返回 `Future<T>`,异常自动映射为 `AppException` 抛出
   - 操作:`resultGuard(() => api.submit())` 返回 `Result<T>`
3. **状态**:`features/goods/provider/goods_provider.dart` ——
   - 查询:顶层 `final goodsList = futureSignal(() => goodsRepository.fetch())`
   - 操作:`asyncSignal` + 顶层操作函数
4. **页面 + 路由**:`features/goods/view/goods_screen.dart`(extends SignalWidget / SignalStatefulWidget),去 `core/router/app_router.dart` 加一行 GoRoute

最后:`dart run build_runner build --delete-conflicting-outputs`(signals 本身**不需要**代码生成,这是给 freezed/retrofit 的)。

**抄哪个模块**:拿数据 → 抄 `home`;做操作 → 抄 `auth`;传值跳页 → 抄 `example` 详情页。

---

## 8. 深入了解

- 官方仓库:<https://github.com/rodydavis/signals.dart>(含文档站链接)
- API 文档:<https://pub.dev/documentation/signals/7.1.0/>
- 本项目相关源码:
  - 查询全链路:`lib/features/home/`(provider → repository → view)
  - 操作全链路:`lib/features/auth/`
  - 四态渲染组件:`lib/core/widget/async_view.dart`
  - 测试写法:`test/widget_test.dart`
