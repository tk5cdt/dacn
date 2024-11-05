// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_large_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostLargeBlock _$PostLargeBlockFromJson(Map<String, dynamic> json) =>
    PostLargeBlock(
      id: json['id'] as String,
      author: const PostAuthorConverter()
          .fromJson(json['author'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      media: const ListMediaConverterFromRemoteConfig()
          .fromJson(json['media'] as List),
      caption: json['caption'] as String,
      action: const BlockActionConverter()
          .fromJson(json['action'] as Map<String, dynamic>?),
      type: json['type'] as String? ?? PostLargeBlock.identifier,
      likersInFollowings: (json['likersInFollowings'] as List<dynamic>?)
              ?.map((e) => User.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PostLargeBlockToJson(PostLargeBlock instance) =>
    <String, dynamic>{
      'type': instance.type,
      'author': const PostAuthorConverter().toJson(instance.author),
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'media':
          const ListMediaConverterFromRemoteConfig().toJson(instance.media),
      'caption': instance.caption,
      'action': const BlockActionConverter().toJson(instance.action),
      'likersInFollowings': instance.likersInFollowings,
    };
