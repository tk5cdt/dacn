// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_author.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostAuthor _$PostAuthorFromJson(Map<String, dynamic> json) => PostAuthor(
      id: json['id'] as String,
      avatarUrl: json['avatarUrl'] as String,
      username: json['username'] as String,
      isConfirmed: json['isConfirmed'] as bool? ?? false,
    );

Map<String, dynamic> _$PostAuthorToJson(PostAuthor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'avatarUrl': instance.avatarUrl,
      'isConfirmed': instance.isConfirmed,
    };
