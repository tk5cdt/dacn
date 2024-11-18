// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section_header_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SectionHeaderBlock _$SectionHeaderBlockFromJson(Map<String, dynamic> json) =>
    SectionHeaderBlock(
      sectionType:
          $enumDecode(_$SectionHeaderBlockTypeEnumMap, json['sectionType']),
      action: const BlockActionConverter()
          .fromJson(json['action'] as Map<String, dynamic>?),
      type: json['type'] as String? ?? SectionHeaderBlock.identifier,
    );

Map<String, dynamic> _$SectionHeaderBlockToJson(SectionHeaderBlock instance) =>
    <String, dynamic>{
      'type': instance.type,
      'sectionType': _$SectionHeaderBlockTypeEnumMap[instance.sectionType]!,
      'action': const BlockActionConverter().toJson(instance.action),
    };

const _$SectionHeaderBlockTypeEnumMap = {
  SectionHeaderBlockType.suggested: 'suggested',
};
