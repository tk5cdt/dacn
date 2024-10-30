import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

extension StringExtension on String {
  /// returns the media type from the passed file name.
  MediaType? get mediaType {
    if (toLowerCase().endsWith('heic')) {
      return MediaType.parse('image/heic');
    } else {
      final mimeType = lookupMimeType(this);
      if (mimeType == null) return null;
      return MediaType.parse(mimeType);
    }
  }
}