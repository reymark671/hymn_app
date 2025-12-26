// lib/services/language_service.dart
import 'package:hymn_app/data/models/language.dart';

class LanguageService {
  static Language getByCode(String code) {
    return allLanguages.firstWhere(
      (l) => l.badgeText == code,
      orElse: () => allLanguages.first,
    );
  }
}
