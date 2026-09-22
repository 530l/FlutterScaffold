import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner.freezed.dart';
part 'banner.g.dart';

/// 首页轮播模型(WanAndroid `/banner/json` 接口的 data 元素)
///
/// 说明:该接口字段本身就是 camelCase,所以不需要 fieldRename;
/// 新建模型时请按后端实际字段风格决定是否配置 fieldRename / JsonConverter。
@freezed
abstract class BannerModel with _$BannerModel {
  const factory BannerModel({
    /// 轮播唯一标识
    required int id,

    /// 展示标题
    @Default('')
    String title,

    /// 点击跳转地址
    @Default('')
    String url,

    /// 轮播图片地址
    @Default('')
    String imagePath,
  }) = _BannerModel;

  /// JSON 反序列化工厂
  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);
}
