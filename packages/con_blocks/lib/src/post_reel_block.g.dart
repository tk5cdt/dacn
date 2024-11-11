// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_reel_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostReelBlock _$PostReelBlockFromJson(Map<String, dynamic> json) =>
    PostReelBlock(
      id: json['id'] as String,
      author: const PostAuthorConverter()
          .fromJson(json['author'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      media: const ListMediaConverterFromRemoteConfig()
          .fromJson(json['media'] as List),
      caption: json['caption'] as String,
      action: const BlockActionConverter()
          .fromJson(json['action'] as Map<String, dynamic>?),
      type: json['type'] as String? ?? PostReelBlock.identifier,
    );

Map<String, dynamic> _$PostReelBlockToJson(PostReelBlock instance) =>
    <String, dynamic>{
      'type': instance.type,
      'author': const PostAuthorConverter().toJson(instance.author),
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'media':
          const ListMediaConverterFromRemoteConfig().toJson(instance.media),
      'caption': instance.caption,
      'action': const BlockActionConverter().toJson(instance.action),
    };
