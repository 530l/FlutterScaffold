import 'package:freezed_annotation/freezed_annotation.dart';

part 'banner.freezed.dart';
part 'banner.g.dart';

/// 首页轮播数据。
@freezed
abstract class BannerModel with _$BannerModel {
  const factory BannerModel({
    required int id,

    @Default('') String title,

    @Default('') String url,

    @Default('') String imagePath,
  }) = _BannerModel;

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);
}
