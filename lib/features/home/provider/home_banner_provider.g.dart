// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_banner_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 首页仓库注入入口。

@ProviderFor(homeRepository)
final homeRepositoryProvider = HomeRepositoryProvider._();

/// 首页仓库注入入口。

final class HomeRepositoryProvider
    extends $FunctionalProvider<HomeRepository, HomeRepository, HomeRepository>
    with $Provider<HomeRepository> {
  /// 首页仓库注入入口。
  HomeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeRepositoryProvider',
        isAutoDispose: false,
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

String _$homeRepositoryHash() => r'29ff021e744cb33fb950eef7018594de30f4f12c';

/// 主壳销毁后释放查询,重新进入时重新请求。

@ProviderFor(homeBanner)
final homeBannerProvider = HomeBannerProvider._();

/// 主壳销毁后释放查询,重新进入时重新请求。

final class HomeBannerProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BannerModel>>,
          List<BannerModel>,
          FutureOr<List<BannerModel>>
        >
    with
        $FutureModifier<List<BannerModel>>,
        $FutureProvider<List<BannerModel>> {
  /// 主壳销毁后释放查询,重新进入时重新请求。
  HomeBannerProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'homeBannerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeBannerHash();

  @$internal
  @override
  $FutureProviderElement<List<BannerModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BannerModel>> create(Ref ref) {
    return homeBanner(ref);
  }
}

String _$homeBannerHash() => r'7881ca17e86fae9d61c35d0f62a580e0ad52a8e6';
