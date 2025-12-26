import 'package:hymn_app/data/db/database_helper.dart';
import 'package:hymn_app/data/models/language.dart';


class SearchService {
  static String extractNumber(String id) {
    return id.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static Language? getLanguageForId(String id) {
    for (final lang in allLanguages) {
      for (final prefix in lang.prefixes) {
        if (id.startsWith(prefix)) return lang;
      }
    }
    return null;
  }

  /// MAIN: Smart Number Search
  static Future<List<Map<String, Object?>>> searchByNumber(
      String query, String currentPrefix) async {

    if (query.trim().isEmpty) return [];

    final db = await DatabaseHelper.database;
    final all = await db.rawQuery('SELECT * FROM hymns');

    String queryNum = extractNumber(query);

    // Filter candidates
    List<Map<String, Object?>> filtered = all.where((row) {
      final id = row["_id"].toString();
      final num = extractNumber(id);

      if (num == queryNum) return true;
      if (num.startsWith(queryNum)) return true;

      return false;
    }).toList();

    // Sort by:
    // 1. exact number match
    // 2. same language prefix
    // 3. alphabetical order
    filtered.sort((a, b) {
      final idA = a["_id"].toString();
      final idB = b["_id"].toString();

      final numA = extractNumber(idA);
      final numB = extractNumber(idB);

      final isExactA = numA == queryNum;
      final isExactB = numB == queryNum;

      if (isExactA && !isExactB) return -1;
      if (!isExactA && isExactB) return 1;

      final startsA = idA.startsWith(currentPrefix);
      final startsB = idB.startsWith(currentPrefix);

      if (startsA && !startsB) return -1;
      if (!startsA && startsB) return 1;

      return idA.compareTo(idB);
    });

    return filtered;
  }

  /// TAB 2 + TAB 3 Simple Search
  static Future<List<Map<String, Object?>>> search(
      int tabIndex, String query) async {

    if (query.trim().isEmpty) return [];

    final db = await DatabaseHelper.database;
    final like = '%$query%';

    if (tabIndex == 1) {
      return await db.rawQuery('''
        SELECT DISTINCT h.*
        FROM hymns h
        LEFT JOIN stanza s ON s.parent_hymn = h._id
        WHERE s.text LIKE ?
        ORDER BY h._id ASC
      ''', [like]);
    }

    if (tabIndex == 2) {
      return await db.rawQuery('''
        SELECT *
        FROM hymns
        WHERE first_stanza_line LIKE ?
        ORDER BY _id ASC
      ''', [like]);
    }

    return [];
  }
}