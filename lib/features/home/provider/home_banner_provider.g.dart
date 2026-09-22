// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_banner_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 首页仓库 provider:注入全局 Dio 实例

@ProviderFor(homeRepository)
final homeRepositoryProvider = HomeRepositoryProvider._();

/// 首页仓库 provider:注入全局 Dio 实例

final class HomeRepositoryProvider
    extends $FunctionalProvider<HomeRepository, HomeRepository, HomeRepository>
    with $Provider<HomeRepository> {
  /// 首页仓库 provider:注入全局 Dio 实例
  HomeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeRepositoryHash();

  @$internal
  @override
  $ProviderElement<HomeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HomeRepository create(Ref ref) {
    return homeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeRepository>(value),
    );
  }
}

String _$homeRepositoryHash() => r'527150c222687d03caabd3f760c8c76b03847713';

/// 首页轮播状态:notifier 驱动的异步三态(加载中 / 数据 / 错误)

@ProviderFor(HomeBannerNotifier)
final homeBannerProvider = HomeBannerNotifierProvider._();

/// 首页轮播状态:notifier 驱动的异步三态(加载中 / 数据 / 错误)
final class HomeBannerNotifierProvider
    extends $AsyncNotifierProvider<HomeBannerNotifier, List<BannerModel>> {
  /// 首页轮播状态:notifier 驱动的异步三态(加载中 / 数据 / 错误)
  HomeBannerNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeBannerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeBannerNotifierHash();

  @$internal
  @override
  HomeBannerNotifier create() => HomeBannerNotifier();
}

String _$homeBannerNotifierHash() =>
    r'c38bea13c5e88cae1e0fe71d3492215700b20083';

/// 首页轮播状态:notifier 驱动的异步三态(加载中 / 数据 / 错误)

abstract class _$HomeBannerNotifier extends $AsyncNotifier<List<BannerModel>> {
  FutureOr<List<BannerModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<BannerModel>>, List<BannerModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<BannerModel>>, List<BannerModel>>,
              AsyncValue<List<BannerModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
