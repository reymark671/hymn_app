// lib/services/language_service.dart
import 'package:hymn_app/data/models/language.dart';

class LanguageService {
  static Language getByCode(String code) {
    return allLanguages.firstWhere(
      (l) => l.badgeText == code,
      orElse: () => allLanguages.first,
    );
  }

  /// Detect language from hymn ID (CB12, FR10, E5, etc.)
  static Language? detectFromHymnId(String hymnId) {
    // Flatten all prefixes with their language
    final entries = <({String prefix, Language lang})>[];

    for (final lang in allLanguages) {
      for (final prefix in lang.prefixes) {
        entries.add((prefix: prefix, lang: lang));
      }
    }

    // Sort prefixes longest-first (CB before C, FR before F)
    entries.sort((a, b) => b.prefix.length.compareTo(a.prefix.length));

    for (final entry in entries) {
      if (hymnId.startsWith(entry.prefix)) {
        return entry.lang;
      }
    }

    return null;
  }
}
