import 'package:con_blocks/con_blocks.dart';
import 'package:json_annotation/json_annotation.dart';

/// {@template insta_blocks_converter}
/// A [JsonConverter] that supports (de)serializing a `List<InstaBlock>`.
/// {@endtemplate}
class ConBlocksConverter
    implements JsonConverter<List<ConBlock>, List<Map<String, dynamic>>> {
  /// {@macro insta_blocks_converter}
  const ConBlocksConverter();

  @override
  List<ConBlock> fromJson(List<Map<String, dynamic>> jsonString) {
    return jsonString
        .map((dynamic e) => ConBlock.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  List<Map<String, dynamic>> toJson(List<ConBlock> blocks) {
    return blocks.map((b) => b.toJson()).toList();
  }
}
