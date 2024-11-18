// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImageMedia _$ImageMediaFromJson(Map<String, dynamic> json) => ImageMedia(
      id: json['media_id'] as String,
      url: json['url'] as String,
      blurHash: json['blurHash'] as String?,
      type: json['type'] as String? ?? ImageMedia.identifier,
    );

Map<String, dynamic> _$ImageMediaToJson(ImageMedia instance) =>
    <String, dynamic>{
      'url': instance.url,
      'type': instance.type,
      'blurHash': instance.blurHash,
      'media_id': instance.id,
    };

MemoryImageMedia _$MemoryImageMediaFromJson(Map<String, dynamic> json) =>
    MemoryImageMedia(
      bytes: const UintConverter().fromJson(json['bytes'] as List<int>),
      id: json['id'] as String,
      url: json['url'] as String? ?? '',
      type: json['type'] as String? ?? MemoryImageMedia.identifier,
    );

Map<String, dynamic> _$MemoryImageMediaToJson(MemoryImageMedia instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'type': instance.type,
      'bytes': const UintConverter().toJson(instance.bytes),
    };
