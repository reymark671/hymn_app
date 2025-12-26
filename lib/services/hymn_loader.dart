// lib/services/hymn_loader.dart
import 'package:hymn_app/data/repositories/hymn_repository.dart';

class HymnLoader {
  static Future<Map<String, Object?>?> loadByPrefix(String prefix) {
    return HymnRepository.loadHymnByPrefix(prefix);
  }

  static Future<Map<String, Object?>?> loadById(String id) {
    return HymnRepository.loadHymnById(id);
  }

  static Future<List<Map<String, Object?>>> loadStanzas(String id) {
    return HymnRepository.loadStanzas(id);
  }
}
