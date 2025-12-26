import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../presentation/screens/chords/guitar_chord.dart';

class ChordService {
  static Future<void> showChordFullscreen({
    required BuildContext context,
    required Map<String, Object?> hymn,
  }) async {
    final hymnId = hymn['_id'].toString();
    final svgPath = "assets/guitarSvg/$hymnId.svg";

    bool exists = await _assetExists(svgPath);

    if (!exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No chords available for $hymnId")),
      );
      return;
    }

    // No longer forcing landscape
    await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ChordFullscreenPage(
          hymnId: hymnId,
          svgPath: svgPath,
        ),
      ),
    );
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
