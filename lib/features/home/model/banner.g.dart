// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BannerModel _$BannerModelFromJson(Map<String, dynamic> json) => _BannerModel(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String? ?? '',
  url: json['url'] as String? ?? '',
  imagePath: json['imagePath'] as String? ?? '',
);

Map<String, dynamic> _$BannerModelToJson(_BannerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'imagePath': instance.imagePath,
    };
