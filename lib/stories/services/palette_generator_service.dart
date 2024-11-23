import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class PaletteGeneratorService {
  /// Extracts colors from an image to determine if white text should be used
  static Future<bool> shouldUseWhiteText({
    required String imageUrl,
    required Rect region,
  }) async {
    try {
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        NetworkImage(imageUrl),
        size: const Size(400, 400),
        region: region,
      );

      final dominantColor = paletteGenerator.dominantColor?.color;
      if (dominantColor == null) return true;

      return _useWhiteForeground(dominantColor);
    } catch (e) {
      // Return true as default in case of error
      return true;
    }
  }

  /// Calculates if white text should be used based on background color luminance
  /// Using W3C guidelines for contrast ratio
  static bool _useWhiteForeground(Color backgroundColor) {
    // Using contrast ratio formula from W3C guidelines
    // https://www.w3.org/TR/WCAG20/#contrast-ratiodef
    return 1.05 / (backgroundColor.computeLuminance() + 0.05) > 4.5;
  }
}
