# FlutterScaffold

Flutter 项目脚手架,提供网络、状态管理、路由、主题和通用交互组件。当前业务为示例。

## 技术栈

| 模块 | 方案 |
|---|---|
| 状态管理 | Riverpod 3 + riverpod_annotation |
| 路由 | go_router |
| 网络 | dio + retrofit |
| 模型 | freezed + json_serializable |
| UI | TDesign Flutter |
| 弹窗 | flutter_smart_dialog + 原生弹窗 |
| 图片 | cached_network_image_ce |
| 权限 | permission_handler |
| 配置存储 | shared_preferences |

## 常用命令

```bash
flutter run
flutter run --dart-define=APP_ENV=prod
dart run build_runner build
```

修改 Riverpod 注解、模型或接口后运行代码生成命令,生成文件不手动编辑。

环境默认是 dev;dev/prod 均使用示例后端,上线前在 `AppConfig` 中配置实际地址。

## 目录与职责

```text
lib/
├── main.dart           # 环境初始化、会话恢复、根作用域
├── app.dart            # 路由、主题和弹窗接入
├── core/
│   ├── config/         # 环境配置
│   ├── network/        # 客户端、响应解包和异常映射
│   ├── router/         # 路由与名称
│   ├── theme/          # 明暗主题
│   ├── widget/         # 异步占位和图片
│   ├── dialog/         # 弹窗、消息和加载提示
│   ├── utils/          # Result、日志、token 存储和权限
│   └── json/           # 字段转换器
└── features/           # 页面、状态、仓库和模型
```

- 页面订阅状态、处理交互和跳转,不访问存储或装配网络客户端。
- provider 注入仓库并管理状态,仓库处理接口与存储。
- `AppDioClient` 只装配客户端;`apiCall` 将网络和模型解析异常映射为 `AppException`。
- `resultGuard` 位于 `core/utils/result.dart`,将操作异常转换为 `Result<T>`。
- Dio 和路由由根作用域创建、释放,避免跨应用实例共享状态。

## 新模块接入

1. 定义模型和接口,通过构造函数向仓库注入客户端。
2. 查询返回 `apiCall(() => api.fetch())`;网络操作返回 `resultGuard(() => apiCall(() => api.submit()))`。
3. 用 `@Riverpod(keepAlive: true)` 函数注入仓库,查询用 `@riverpod` 异步函数,操作用注解类管理状态。
4. 页面使用 `ConsumerWidget` 或 `ConsumerStatefulWidget`,通过 `ref.watch` 订阅、`ref.read` 调用操作。

代码注释使用简洁中文,说明意图和边界。纯页面状态继续使用 `setState`。
Riverpod 用法见 [docs/riverpod.md](docs/riverpod.md)。

## 页面与公共组件

主壳通过 `IndexedStack` 保留探索、创作、资产、我的四个 tab。切 tab 保留查询结果,主壳销毁后首页查询自动释放并取消请求。新增 tab 时保持页面与底部导航顺序一致。

`AsyncView` 展示加载、空数据、错误和内容;下拉刷新保留旧内容。操作返回 `Result<T>`,由页面决定提示和跳转。

TDesign 组件直接使用,公共组件只统一项目样式和交互。`third_party/tdesign_flutter` 是兼容 Flutter 3.47 的本地补丁,上游兼容后核对并移除覆盖。

业务权限按实际功能添加到 Android 清单和 iOS 用途描述中,再调用 `Permissions` 检查或申请。

当前登录为本地模拟,token 使用普通偏好存储,Android release 使用调试签名。这些示例配置需要在正式上线前替换。
