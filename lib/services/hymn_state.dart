// lib/services/hymn_state.dart
import 'package:shared_preferences/shared_preferences.dart';

class HymnState {
  static Future<void> save(String hymnId, String lang) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("last_hymn_id", hymnId);
    prefs.setString("last_language", lang);
  }

  static Future<Map<String, String?>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "id": prefs.getString("last_hymn_id"),
      "lang": prefs.getString("last_language"),
    };
  }
}
