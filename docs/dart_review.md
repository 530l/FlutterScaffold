# Dart 与 Flutter 源码审查

本次审查以项目实际使用的 Dart 3.13.2、Flutter 3.47.2 为准。
`pubspec.yaml` 的 `sdk: ^3.13.2` 与所用语法匹配。当前可用技能中没有 Dart／Flutter 专用
skill，因此直接参考官方文档，并对照本地 Flutter SDK 与 TDesign 0.2.7 源码。

## 已确认的用法

- `super.key`、增强枚举、records 解构、`switch` 表达式与通配符 `_` 均适用于当前 SDK。
- 页面以独立 `StatelessWidget` 组合业务区块，并为静态组件使用 `const` 构造。
- 输入与筛选保留局部状态；业务记录使用 Riverpod Notifier，事件中用 `ref.read` 调用操作。
- 异步交互返回后检查 `mounted`，定时器、控制器与路由均有释放逻辑。
- TDesign 使用公共入口导出的 `TDTabBar`，不直接引用内部 `TDHorizontalTabBar`。

## 本次修正

- `WellnessState.copyWith` 复用未变化的不可变列表，避免只改变保存进度或设置时，
  `select((state) => state.entries)` 仍因列表实例变化而重建。
- 数据模型使用 `final class` 明确关闭外部继承；不可变性由 `final` 字段和冻结列表保证。
- JSON 边界使用 `Map<String, Object?>` 与 `List<Object?>`，通过明确的类型转换读取字段。
- 可选 Widget 使用 `?action`、`?trailing`。这是 Dart 3.8 起支持的空感知集合元素，
  会跳过 `null`，无需额外判断和强制解包。
- 错误消息与专注状态分支使用 `switch` 模式匹配，替换多层三元表达式。
- 多行条件补全花括号；删除习惯时先取得非空局部变量，移除 `widget.habit!`。
- 专注返回确认增加重复触发保护；删除确认期间禁用重复操作。
- 专注开始状态单独记录，首秒内暂停后仍可继续，也不会重新开放时长选择。
- `ThemeData` 使用 `AppBarThemeData` 配置导航栏，并缓存明暗主题实例。

## 官方依据

- [Effective Dart：命名、导入与格式](https://dart.dev/effective-dart/style)
- [Dart：空感知集合元素](https://dart.dev/language/collections#null-aware-elements)
- [Dart：模式类型](https://dart.dev/language/pattern-types)
- [Dart：类修饰符](https://dart.dev/language/class-modifiers)
- [Flutter：性能最佳实践](https://docs.flutter.dev/perf/best-practices)
- [Flutter：组件主题类型规范化](https://docs.flutter.dev/release/breaking-changes/component-theme-normalization)
- [Riverpod：使用 select 控制重建](https://riverpod.dev/docs/how_to/select)

采用新语法的原则是减少重复、明确类型与控制分支，不要求每一处表达式都改成最新写法。

本次进行了人工源码审查和格式化，仅运行 `git diff --check` 作为检查；
未运行 `dart analyze`、测试或构建，因此不将源码审查结论作为编译成功的证明。
