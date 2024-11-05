// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sponsored_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostSponsoredBlock _$PostSponsoredBlockFromJson(Map<String, dynamic> json) =>
    PostSponsoredBlock(
      id: json['id'] as String,
      author: const PostAuthorConverter()
          .fromJson(json['author'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      media: const ListMediaConverterFromRemoteConfig()
          .fromJson(json['media'] as List),
      caption: json['caption'] as String,
      action: const BlockActionConverter()
          .fromJson(json['action'] as Map<String, dynamic>?),
      type: json['type'] as String? ?? PostSponsoredBlock.identifier,
    );

Map<String, dynamic> _$PostSponsoredBlockToJson(PostSponsoredBlock instance) =>
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
