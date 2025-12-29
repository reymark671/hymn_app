// lib/services/hymn_state.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HymnState {
  static const _keyLastByLanguage = 'last_by_language';

  /// Save last hymn for a specific language
  static Future<void> save(String hymnId, String lang) async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_keyLastByLanguage);
    final Map<String, String> map = raw != null
        ? Map<String, String>.from(jsonDecode(raw))
        : {};

    map[lang] = hymnId;

    await prefs.setString(_keyLastByLanguage, jsonEncode(map));
  }

  /// Load last hymn for a specific language
  static Future<String?> loadLastForLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyLastByLanguage);

    if (raw == null) return null;

    final map = Map<String, dynamic>.from(jsonDecode(raw));
    return map[lang] as String?;
  }

  /// Load the most recently viewed hymn (any language)
  static Future<Map<String, String?>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyLastByLanguage);

    if (raw == null) {
      return {"id": null, "lang": null};
    }

    final map = Map<String, dynamic>.from(jsonDecode(raw));
    if (map.isEmpty) {
      return {"id": null, "lang": null};
    }

    final lastLang = map.keys.last;
    return {"id": map[lastLang] as String?, "lang": lastLang};
  }
}
