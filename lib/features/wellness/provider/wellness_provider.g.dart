// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wellness_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(wellnessRepository)
final wellnessRepositoryProvider = WellnessRepositoryProvider._();

final class WellnessRepositoryProvider
    extends
        $FunctionalProvider<
          WellnessRepository,
          WellnessRepository,
          WellnessRepository
        >
    with $Provider<WellnessRepository> {
  WellnessRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wellnessRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wellnessRepositoryHash();

  @$internal
  @override
  $ProviderElement<WellnessRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WellnessRepository create(Ref ref) {
    return wellnessRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WellnessRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WellnessRepository>(value),
    );
  }
}

String _$wellnessRepositoryHash() =>
    r'7067c71f2752dab6a933d5299298b6702057c16f';

/// 启动时覆盖恢复的初值；默认值让独立页面和测试作用域也能使用。

@ProviderFor(initialWellnessState)
final initialWellnessStateProvider = InitialWellnessStateProvider._();

/// 启动时覆盖恢复的初值；默认值让独立页面和测试作用域也能使用。

final class InitialWellnessStateProvider
    extends $FunctionalProvider<WellnessState, WellnessState, WellnessState>
    with $Provider<WellnessState> {
  /// 启动时覆盖恢复的初值；默认值让独立页面和测试作用域也能使用。
  InitialWellnessStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initialWellnessStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialWellnessStateHash();

  @$internal
  @override
  $ProviderElement<WellnessState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WellnessState create(Ref ref) {
    return initialWellnessState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WellnessState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WellnessState>(value),
    );
  }
}

String _$initialWellnessStateHash() =>
    r'ff3a85da53bd1737b1ceb6fb62f32d1ee4bd5f8c';

/// 类负责可修改的业务状态，持久化成功后才提交新状态。
/// 类名首字母转小写，再追加 Provider：Wellness → wellnessProvider。
/// _$Wellness 是生成的基类；build 返回初值，页面通过 notifier 调用修改方法。

@ProviderFor(Wellness)
final wellnessProvider = WellnessProvider._();

/// 类负责可修改的业务状态，持久化成功后才提交新状态。
/// 类名首字母转小写，再追加 Provider：Wellness → wellnessProvider。
/// _$Wellness 是生成的基类；build 返回初值，页面通过 notifier 调用修改方法。
final class WellnessProvider
    extends $NotifierProvider<Wellness, WellnessState> {
  /// 类负责可修改的业务状态，持久化成功后才提交新状态。
  /// 类名首字母转小写，再追加 Provider：Wellness → wellnessProvider。
  /// _$Wellness 是生成的基类；build 返回初值，页面通过 notifier 调用修改方法。
  WellnessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wellnessProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wellnessHash();

  @$internal
  @override
  Wellness create() => Wellness();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WellnessState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WellnessState>(value),
    );
  }
}

String _$wellnessHash() => r'e20d2154683b3d84960eaedde09ed1f14482a380';

/// 类负责可修改的业务状态，持久化成功后才提交新状态。
/// 类名首字母转小写，再追加 Provider：Wellness → wellnessProvider。
/// _$Wellness 是生成的基类；build 返回初值，页面通过 notifier 调用修改方法。

abstract class _$Wellness extends $Notifier<WellnessState> {
  WellnessState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WellnessState, WellnessState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WellnessState, WellnessState>,
              WellnessState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// 跨过午夜后更新日期,页面无需重启即可开始新一天的打卡。

@ProviderFor(CurrentDay)
final currentDayProvider = CurrentDayProvider._();

/// 跨过午夜后更新日期,页面无需重启即可开始新一天的打卡。
final class CurrentDayProvider extends $NotifierProvider<CurrentDay, DateTime> {
  /// 跨过午夜后更新日期,页面无需重启即可开始新一天的打卡。
  CurrentDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentDayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentDayHash();

  @$internal
  @override
  CurrentDay create() => CurrentDay();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$currentDayHash() => r'f45ea23b970979273e6e70c4e6bf4208a8ce7f8c';

/// 跨过午夜后更新日期,页面无需重启即可开始新一天的打卡。

abstract class _$CurrentDay extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
