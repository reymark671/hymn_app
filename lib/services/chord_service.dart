import 'package:flutter/services.dart';

class ChordService {
  /// Checks if chord asset exists and returns SVG path if available
  static Future<String?> getChordSvgPath({
    required Map<String, Object?> hymn,
  }) async {
    final hymnId = hymn['_id'].toString();
    final svgPath = "assets/guitarSvg/$hymnId.svg";

    final exists = await _assetExists(svgPath);
    if (!exists) return null;

    return svgPath;
  }

  static Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
    }
  }
}
