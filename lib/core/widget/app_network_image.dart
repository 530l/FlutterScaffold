import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 统一网络图片组件:封装 cached_network_image_ce 的 CachedNetworkImage
///
/// 占位统一为淡色容器 + 小号 TDLoading,加载失败统一为 TD 图片错误图标;
/// 圆角通过 [borderRadius] 控制(内部用 ClipRRect 裁剪,不影响原始布局尺寸)。
///
/// ```dart
/// AppNetworkImage(
///   url,
///   width: 80,
///   height: 80,
///   borderRadius: 8,
///   fit: BoxFit.cover,
/// )
/// ```
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
  });

  /// 图片地址
  final String imageUrl;

  /// 宽度,为 null 时由父容器约束决定
  final double? width;

  /// 高度,为 null 时由父容器约束决定
  final double? height;

  /// 填充模式
  final BoxFit? fit;

  /// 圆角半径,为 null 时不裁剪
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      // 加载占位:淡色底 + 小号加载圈
      placeholder: (context, url) => _buildPlaceholder(context),
      // 加载失败:TD 图片错误图标
      // 注:4.12.0 起 errorWidget 已废弃,统一改用 errorBuilder
      errorBuilder: (context, error, stackTrace) => _buildError(context),
    );
    if (borderRadius == null) {
      return image;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius!),
      child: image,
    );
  }

  /// 构建加载占位:淡色容器 + 小号 TDLoading
  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: TDTheme.of(context).grayColor1,
      alignment: Alignment.center,
      child: const TDLoading(
        size: TDLoadingSize.small,
        icon: TDLoadingIcon.circle,
      ),
    );
  }

  /// 构建加载失败占位:淡色容器 + TD 图片错误图标
  Widget _buildError(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: TDTheme.of(context).grayColor1,
      alignment: Alignment.center,
      child: Icon(
        TDIcons.image_error,
        size: 24,
        color: TDTheme.of(context).textColorPlaceholder,
      ),
    );
  }
}
