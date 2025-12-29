import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _key = 'favorite_hymns';

  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<bool> isFavorite(String hymnId) async {
    final favs = await getFavorites();
    return favs.contains(hymnId);
  }

  static Future<void> toggleFavorite(String hymnId) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList(_key) ?? [];

    if (favs.contains(hymnId)) {
      favs.remove(hymnId);
    } else {
      favs.add(hymnId);
    }

    await prefs.setStringList(_key, favs);
  }
}
