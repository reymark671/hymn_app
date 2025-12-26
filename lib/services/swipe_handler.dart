// lib/services/swipe_handler.dart
import 'package:hymn_app/services/hymn_navigator.dart';

class SwipeHandler {
  static Future<String?> next(String prefix, int currentNo) {
    return HymnNavigator.next(prefix, currentNo);
  }

  static Future<String?> previous(String prefix, int currentNo) {
    return HymnNavigator.previous(prefix, currentNo);
  }
}
