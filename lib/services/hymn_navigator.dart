import 'package:hymn_app/data/db/database_helper.dart';

class HymnNavigator {
  /// Returns the NEXT hymn available within the same prefix.
  static Future<String?> next(String prefix, int currentNo) async {
    final db = await DatabaseHelper.database;

    final rows = await db.query(
      'hymns',
      where: '_id LIKE ?',
      whereArgs: ['$prefix%'],
      orderBy: '_id ASC',
    );

    // Build map: number → actual hymn ID
    final Map<int, String> map = {};

    for (final r in rows) {
      final id = r['_id']?.toString() ?? '';
      final no = int.tryParse(r['no']?.toString() ?? '');

      if (no != null) {
        map[no] = id;
      }
    }

    if (map.isEmpty) return null;

    final numbers = map.keys.toList()..sort();

    // find the next available number
    for (final n in numbers) {
      if (n > currentNo) {
        return map[n]; // return actual ID e.g. "CB7"
      }
    }

    return null; // no next hymn
  }

  /// Returns the PREVIOUS hymn available within the same prefix.
  static Future<String?> previous(String prefix, int currentNo) async {
    final db = await DatabaseHelper.database;

    final rows = await db.query(
      'hymns',
      where: '_id LIKE ?',
      whereArgs: ['$prefix%'],
      orderBy: '_id ASC',
    );

    final Map<int, String> map = {};

    for (final r in rows) {
      final id = r['_id']?.toString() ?? '';
      final no = int.tryParse(r['no']?.toString() ?? '');

      if (no != null) {
        map[no] = id;
      }
    }

    if (map.isEmpty) return null;

    final numbers = map.keys.toList()..sort();

    // find the closest lower available number
    for (final n in numbers.reversed) {
      if (n < currentNo) {
        return map[n]; // return "CB1"
      }
    }

    return null;
  }
}
