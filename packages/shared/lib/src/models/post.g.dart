// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      author: const UserConverter()
          .fromJson(json['author'] as Map<String, dynamic>),
      caption: json['caption'] as String,
      media: json['media'] == null
          ? const []
          : const ListMediaConverterFromDb().fromJson(json['media'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'author': const UserConverter().toJson(instance.author),
      'caption': instance.caption,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'media': const ListMediaConverterFromDb().toJson(instance.media),
    };
