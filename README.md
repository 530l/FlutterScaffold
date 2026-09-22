# FlutterScaffold

团队 Flutter 项目脚手架:网络、状态管理、路由、JSON 管理、公共组件、弹窗、权限开箱即用。

## 技术栈

| 维度 | 方案 |
|---|---|
| 状态管理 | Riverpod 3(hooks_riverpod + riverpod_generator 注解风格) |
| 路由 | go_router(平铺路由表) |
| 网络 | dio + retrofit(注解生成 API 客户端,统一拦截器 + Result 包装) |
| UI 基座 | tdesign_flutter(TDButton/TDInput 等基础组件直接使用,不二次封装) |
| 弹窗 | flutter_smart_dialog(Toast/全局 Loading)+ 原生 showDialog 封装 |
| 图片 | cached_network_image_ce |
| 模型 | freezed + json_serializable(不可变模型,代码生成) |
| 权限 | permission_handler |

## 常用命令

```bash
# 跑起来(默认 dev 环境)
flutter run

# 指定环境
flutter run --dart-define=APP_ENV=prod   # 可选值:dev(默认)/ prod

# 模型/接口/provider 改动后重新生成代码(开发期可换成 watch)
dart run build_runner build --delete-conflicting-outputs

# 静态检查与测试
flutter analyze
flutter test
```

## 目录结构

```
lib/
├── main.dart               # 入口:环境初始化 + ProviderScope
├── app.dart                # 根组件:路由 + 主题 + smart_dialog 接线
├── core/                   # 与业务无关的公共能力
│   ├── config/             # 环境配置(AppEnv / apiBaseUrl)
│   ├── network/            # dio 装配、拦截器、异常体系、resultGuard
│   ├── router/             # 路由表与常量
│   ├── theme/              # TDesign 基座主题
│   ├── widget/             # 状态占位/AsyncView/网络图片
│   ├── dialog/             # AppDialog/BottomSheet/Toast/Loading
│   ├── permission/         # 权限申请与引导
│   ├── json/               # 常用 JsonConverter
│   └── utils/              # Result / Logger / RiverpodLogger
└── features/               # 业务模块(照 home 模块复制)
    ├── home/               # 示例:真实网络请求全链路
    └── auth/               # 示例:假登录 + token 存取
```

## 新模块四步接入法(照抄 home 模块)

1. **建模型**:`features/<模块>/model/xxx.dart` —— `@freezed` + `@JsonSerializable` 定义不可变模型;
2. **建接口**:`features/<模块>/repository/xxx_api.dart` —— `@RestApi()` 抽象类声明接口,`repository/xxx_repository.dart` 里用 `resultGuard` 包一层返回 `Result<T>`;
3. **建状态**:`features/<模块>/provider/xxx_provider.dart` —— `@riverpod` AsyncNotifier,`ref.onDispose` 挂 CancelToken;
4. **建页面 + 注册路由**:`features/<模块>/view/xxx_screen.dart`,然后在 `core/router/app_router.dart` 追加一行 GoRoute。

最后跑 `dart run build_runner build --delete-conflicting-outputs` 生成代码。

## 约定

- **代码注释一律中文**(团队硬性规范)
- 仓库层返回 `Result<T>`,UI 层 switch 穷举处理,不在页面里 try/catch
- 业务错误文案集中在 `AppExceptionMapper`,不要在页面散落硬编码
- TDesign 基础组件(TDButton/TDInput 等)直接使用,不做二次封装;新公共组件先放 feature 内,第三次复用时才下沉 `core/widget`
- 新权限:放开 `AndroidManifest.xml` / `Info.plist` 里对应注释块,并在 `AppPermission` 枚举补一项

## 环境说明

- dev / prod 由 `--dart-define=APP_ENV` 控制,baseUrl 等环境差异集中改 `core/config/app_config.dart`
- 示例后端为 WanAndroid(国内直连免鉴权),接入真实后端时改 `AppConfig.apiBaseUrl` 与 `core/network/api_response.dart` 的响应壳字段
