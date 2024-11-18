// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoMedia _$VideoMediaFromJson(Map<String, dynamic> json) => VideoMedia(
      id: json['media_id'] as String,
      url: json['url'] as String,
      firstFrameUrl: json['firstFrameUrl'] as String? ?? '',
      blurHash: json['blurHash'] as String?,
      type: json['type'] as String? ?? VideoMedia.identifier,
    );

Map<String, dynamic> _$VideoMediaToJson(VideoMedia instance) =>
    <String, dynamic>{
      'url': instance.url,
      'type': instance.type,
      'blurHash': instance.blurHash,
      'media_id': instance.id,
      'firstFrameUrl': instance.firstFrameUrl,
    };
