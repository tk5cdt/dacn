// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NavigateToPostAuthorProfileAction _$NavigateToPostAuthorProfileActionFromJson(
        Map<String, dynamic> json) =>
    NavigateToPostAuthorProfileAction(
      authorId: json['authorId'] as String,
      type: json['type'] as String? ??
          NavigateToPostAuthorProfileAction.identifier,
    );

Map<String, dynamic> _$NavigateToPostAuthorProfileActionToJson(
        NavigateToPostAuthorProfileAction instance) =>
    <String, dynamic>{
      'authorId': instance.authorId,
      'type': instance.type,
    };

NavigateToSponsoredPostAuthorProfileAction
    _$NavigateToSponsoredPostAuthorProfileActionFromJson(
            Map<String, dynamic> json) =>
        NavigateToSponsoredPostAuthorProfileAction(
          authorId: json['authorId'] as String,
          promoPreviewImageUrl: json['promoPreviewImageUrl'] as String,
          promoUrl: json['promoUrl'] as String,
          type: json['type'] as String? ??
              NavigateToSponsoredPostAuthorProfileAction.identifier,
        );

Map<String, dynamic> _$NavigateToSponsoredPostAuthorProfileActionToJson(
        NavigateToSponsoredPostAuthorProfileAction instance) =>
    <String, dynamic>{
      'authorId': instance.authorId,
      'promoPreviewImageUrl': instance.promoPreviewImageUrl,
      'promoUrl': instance.promoUrl,
      'type': instance.type,
    };

UnknownBlockAction _$UnknownBlockActionFromJson(Map<String, dynamic> json) =>
    UnknownBlockAction(
      type: json['type'] as String? ?? UnknownBlockAction.identifier,
    );

Map<String, dynamic> _$UnknownBlockActionToJson(UnknownBlockAction instance) =>
    <String, dynamic>{
      'type': instance.type,
    };
