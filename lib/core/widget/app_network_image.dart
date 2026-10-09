import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

/// 统一网络图片的占位、错误和圆角。
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
  });

  final String imageUrl;

  final double? width;

  final double? height;

  final BoxFit? fit;

  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildPlaceholder(context),
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
