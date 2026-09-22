import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'logger.dart';

/// Riverpod 生命周期观察者:开发环境打印 provider 增删改,便于排查依赖关系
///
/// 挂载位置:main.dart 的 ProviderScope(observers: [...])
/// (riverpod 3.4.x 起回调统一改为 ProviderObserverContext 参数风格)
final class RiverpodLogger extends ProviderObserver {
  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    Logger.d('provider 新建: ${context.provider.name ?? context.provider.runtimeType}');
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    Logger.d('provider 更新: ${context.provider.name ?? context.provider.runtimeType}');
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    Logger.d('provider 销毁: ${context.provider.name ?? context.provider.runtimeType}');
  }
}
