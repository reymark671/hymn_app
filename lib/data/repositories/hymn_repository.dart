import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';

class HymnRepository {
  // ----------------------------------------------------
  // 📖 Load hymn by exact ID (E12, T12, CB12...)
  // ----------------------------------------------------
  static Future<Map<String, Object?>?> loadHymnById(String id) async {
    final db = await DatabaseHelper.database;

    final rows = await db.query(
      'hymns',
      where: '_id = ?',
      whereArgs: [id],
    );

    return rows.isNotEmpty ? rows.first : null;
  }

  // ----------------------------------------------------
  // 📖 Load stanzas for a hymn
  // ----------------------------------------------------
  static Future<List<Map<String, Object?>>> loadStanzas(String hymnId) async {
    final db = await DatabaseHelper.database;

    return db.query(
      'stanza',
      where: 'parent_hymn = ?',
      whereArgs: [hymnId],
      orderBy: 'n_order ASC',
    );
  }

  // ----------------------------------------------------
  // 📖 Load first hymn for language prefix
  // ----------------------------------------------------
  static Future<Map<String, Object?>?> loadHymnByPrefix(String prefix) async {
    final db = await DatabaseHelper.database;

    final rows = await db.query(
      'hymns',
      where: '_id LIKE ?',
      whereArgs: ['$prefix%'],
      orderBy: '_id ASC',
      limit: 1,
    );

    return rows.isNotEmpty ? rows.first : null;
  }

  // ----------------------------------------------------
  // 🔗 Dynamic Related Mapping
  // ----------------------------------------------------
  static Future<String?> findRelatedIdDynamic(
      Map<String, Object?> currentHymn, String targetPrefix) async {
    final String currentId = currentHymn['_id']?.toString() ?? "";
    final relatedRaw = currentHymn['related']?.toString() ?? "";
    final parts = relatedRaw.split(',');

    print("DEBUG related: $relatedRaw");

    // 1️⃣ Direct match
    for (String p in parts) {
      p = p.trim();
      if (p.isEmpty) continue;

      final prefix = RegExp(r'^[A-Za-z]+').stringMatch(p);
      if (prefix != null &&
          prefix.toUpperCase() == targetPrefix.toUpperCase()) {
        return p;
      }
    }

    // 2️⃣ Reverse lookup
    final db = await DatabaseHelper.database;

    final reverse = await db.query(
      'hymns',
      where: 'related LIKE ?',
      whereArgs: ['%$currentId%'],
    );

    for (final row in reverse) {
      final id = row['_id']?.toString() ?? "";
      final prefix = RegExp(r'^[A-Za-z]+').stringMatch(id);

      if (prefix != null &&
          prefix.toUpperCase() == targetPrefix.toUpperCase()) {
        return id;
      }

      final r = row['related']?.toString() ?? "";
      for (var t in r.split(',')) {
        t = t.trim();
        final tpfx = RegExp(r'^[A-Za-z]+').stringMatch(t);
        if (tpfx != null && tpfx.toUpperCase() == targetPrefix.toUpperCase()) {
          return t;
        }
      }
    }

    // 3️⃣ Fallback prefix lookup
    final fallbackRows = await db.query(
      'hymns',
      where: '_id LIKE ?',
      whereArgs: ['$targetPrefix%'],
      limit: 1,
    );

    if (fallbackRows.isNotEmpty) {
      return fallbackRows.first['_id'].toString();
    }

    return null;
  }
}
