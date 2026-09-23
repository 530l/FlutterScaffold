# FlutterScaffold

团队 Flutter 项目脚手架:网络、状态管理、路由、JSON 管理、公共组件、弹窗、权限开箱即用。

## 技术栈

| 维度 | 方案 |
|---|---|
| 状态管理 | signals 7(顶层信号 `futureSignal` 查询 / `asyncSignal` + 顶层操作函数,`SignalWidget` 读 `.value` 自动订阅重建) |
| 路由 | go_router(平铺路由表) |
| 网络 | dio + retrofit(注解生成 API 客户端,统一拦截器解包 + 异常收敛) |
| UI 基座 | tdesign_flutter(TDButton/TDInput 等基础组件直接使用,不二次封装) |
| 弹窗 | flutter_smart_dialog(Toast/全局 Loading)+ 原生 showDialog 封装 |
| 图片 | cached_network_image_ce |
| 模型 | freezed + json_serializable(不可变模型,代码生成;简单状态类轻量手写) |
| 权限 | permission_handler |

## 常用命令

```bash
# 跑起来(默认 dev 环境)
flutter run

# 指定环境
flutter run --dart-define=APP_ENV=prod   # 可选值:dev(默认)/ prod

# 模型/接口改动后重新生成代码(开发期可换成 watch;signals 无需代码生成)
dart run build_runner build --delete-conflicting-outputs

# 静态检查与测试
flutter analyze
flutter test
```

## 目录结构

```
lib/
├── main.dart               # 入口:环境初始化 + 登录态恢复(restoreAuth)
├── app.dart                # 根组件:路由 + 主题 + smart_dialog 接线
├── core/                   # 与业务无关的公共能力
│   ├── config/             # 环境配置(AppEnv / apiBaseUrl)
│   ├── network/            # dio 装配、拦截器、统一异常、apiCall/resultGuard
│   ├── router/             # 路由表与常量
│   ├── theme/              # TDesign 基座主题
│   ├── widget/             # 状态占位/AsyncView(四态+下拉)/网络图片
│   ├── dialog/             # AppDialog/BottomSheet/Toast/Loading
│   ├── utils/              # 日志/Result/token 存取/权限工具类等
│   └── json/               # 常用 JsonConverter
└── features/               # 业务模块(照 home 模块复制)
    ├── main/               # 主壳页:底部 4 tab(探索/创作/资产/我的)
    ├── home/               # 示例:真实网络请求全链路(Query 模式),挂在「探索」tab
    ├── create/             # 占位 tab 页(创作):详情页传值/回值示例入口
    ├── assets/             # 占位 tab 页(资产)
    ├── mine/               # 占位 tab 页(我的)
    ├── example/            # 示例:详情页(query 传值进 / pop 带值出)
    └── auth/               # 示例:假登录 + token 存取(Action 模式)
```

## 底部 tab 主框架与路由

主壳页 `features/main/view/main_page.dart`:body 为 `IndexedStack`(四个 tab 页面常驻,切 tab 不重建不丢状态),底部为 TDesign `TDBottomTabBar`(iconText 模式;tab 文案的选中色组件自动处理,图标需按选中/未选中各传一个不同色的 Icon)。tab 当前索引是壳页的本地 UI 状态,不进信号。

路由平铺在 `core/router/app_router.dart`:`/` 主壳页、`/detail` 详情页(传值/回值示例)、`/login` 登录页。detail 入参经 query 参数(`?title=创作`)传递,返回值经 `context.pop(value)` 带回、跳转方 `await context.push<String>(...)` 接住。

新增 tab 两步:在 `main_page.dart` 的 `IndexedStack.children` 放入页面 + `navigationTabs` 加一项(两处顺序保持一致),无需动路由。

## 新模块四步接入法(照抄 home / auth 模块)

1. **建模型**:`features/<模块>/model/xxx.dart` —— 复杂模型用 `@freezed` + `@JsonSerializable` 定义,纯状态轻量类直接手写;
2. **建接口与仓库**:`features/<模块>/repository/xxx_api.dart` —— `@RestApi()` 抽象类声明接口;
   - **Query 数据查询**:`xxx_repository.dart` 里直接用 `apiCall(() => api.fetch())` 返回 `Future<T>`,底层异常统一映射为 `AppException` 向上抛出;
   - **Action 用户操作**:`xxx_repository.dart` 里用 `resultGuard(() => api.submit())` 返回 `Result<T>`;
3. **建状态**:`features/<模块>/provider/xxx_provider.dart`(文件名沿用,内容为顶层信号)——
   - **Query 数据查询**:顶层 `final xxx = futureSignal(() => repository.fetch())`,`AsyncState` 自动管理 loading/error/data;下拉刷新用 `refresh()`(保留旧数据置 loading),错误重试用 `reload()`;
   - **Action 用户操作**:顶层 `asyncSignal` + 顶层操作函数驱动(`setLoading`/`setValue`/`setError`),函数返回 `Result<T>`,供 UI 穷举模式匹配;
   - 仓库由顶层可变变量持有(唯一的注入缝,widget 测试直接重新赋值为假实现);
4. **建页面 + 注册路由**:`features/<模块>/view/xxx_screen.dart`(页面 `extends SignalWidget`,有状态用 `SignalStatefulWidget`,`build` 里读信号 `.value` 即自动订阅重建),然后在 `core/router/app_router.dart` 追加一行 GoRoute。

最后跑 `dart run build_runner build --delete-conflicting-outputs` 生成代码。

## 约定

- **代码注释一律中文**(团队硬性规范)
- **查询走 signals 三/四态**,UI 直接用 `AsyncView` 处理(入参 `value` 为 `AsyncState<T>`,data/error 分支需写在 loading 之前),不经过二次包装;
- **操作层返回 `Result<T>`**,UI 层 switch/模式匹配穷举处理,不在页面里 try/catch;
- 业务错误文案集中在 `AppExceptionMapper`,不要在页面散落硬编码;
- TDesign 基础组件(TDButton/TDInput 等)直接使用,不做二次封装;新公共组件先放 feature 内,第三次复用时才下沉 `core/widget`;
- 新权限:放开 `AndroidManifest.xml` / `Info.plist` 里对应注释块,业务侧直接 `Permissions.request(Permission.xxx)`(工具类见 `core/utils/permissions.dart`)。

## 环境说明

- dev / prod 由 `--dart-define=APP_ENV` 控制,baseUrl 等环境差异集中改 `core/config/app_config.dart`
- 示例后端为 WanAndroid(国内直连免鉴权),接入真实后端时改 `AppConfig.apiBaseUrl` 与 `core/network/app_dio_client.dart` 的 `_EnvelopeInterceptor` 响应壳字段
