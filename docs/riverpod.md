# 项目里的 Riverpod 用法

## 注解与依赖注入

`@riverpod` / `@Riverpod(...)` 告诉代码生成器创建 provider。
注解本身不是依赖注入容器；生成的 provider 配合 `ProviderScope`、`ref.watch`、
`ref.read` 和 `overrideWithValue`，实现依赖的创建、获取、替换与生命周期管理。

本项目使用 `@Riverpod(keepAlive: true)`，让本地记录和仓库在根作用域内保持可用。
`@riverpod` 等价于使用默认配置，默认在没有监听者时自动释放状态。

## 名称怎么生成

默认规则如下，不需要手写 provider 变量：

| 源码声明 | 生成名称 |
|---|---|
| `wellnessRepository(Ref ref)` 函数 | `wellnessRepositoryProvider` |
| `initialWellnessState(Ref ref)` 函数 | `initialWellnessStateProvider` |
| `Wellness extends _$Wellness` 类 | `wellnessProvider` |
| `CurrentDay extends _$CurrentDay` 类 | `currentDayProvider` |

函数保留名字并追加 `Provider`；类先把首字母改为小写，再追加 `Provider`。
`_$Wellness` 是生成的 Notifier 基类，业务类继承它后实现 `build()` 返回初始状态。
生成结果位于同目录的 `.g.dart`，通过 `part` 接入，不直接修改。

## 依赖链

```text
ProviderScope 启动覆盖
├── wellnessRepositoryProvider     本地存储仓库
└── initialWellnessStateProvider   启动时恢复的记录
    └── wellnessProvider          共享业务状态和修改操作
        └── 页面与局部 ConsumerWidget
```

`main.dart` 先调用仓库恢复数据，再覆盖仓库和初值 provider。
`Wellness.build()` 读取初值；操作读取仓库、保存记录，成功后提交新状态。
保存期间禁用重复操作，失败时恢复之前的状态，并由交互位置显示提示。

## 页面如何使用

```dart
// watch 订阅变化，数据变化时重新构建页面。
final state = ref.watch(wellnessProvider);

// select 只关注当前组件需要的字段。
final darkMode = ref.watch(
  wellnessProvider.select((state) => state.darkMode),
);

// read 获取控制器并调用操作，不为这次读取建立订阅。
await ref.read(wellnessProvider.notifier).toggleHabit(habit.id, day);
```

共享业务状态使用 Notifier 类，提供明确的修改方法；创建仓库或提供启动初值时使用函数即可。
输入框、筛选条件、心情草稿和倒计时属于页面局部状态，继续使用 `setState`。
