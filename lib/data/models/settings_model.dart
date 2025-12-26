import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SettingsModel extends ChangeNotifier {
  double fontSize = 16.0;
  bool nightMode = false;
  bool keepDisplayOn = false;
  Set<String> disabledLanguages = {};

  SettingsModel() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    fontSize = prefs.getDouble("fontSize") ?? 16.0;
    nightMode = prefs.getBool("nightMode") ?? false;
    keepDisplayOn = prefs.getBool("keepDisplayOn") ?? false;
    disabledLanguages =
        prefs.getStringList("disabledLanguages")?.toSet() ?? {};

    // Apply wakelock
    if (keepDisplayOn) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }

    notifyListeners();
  }

  Future<void> updateFontSize(double value) async {
    fontSize = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("fontSize", value);
    notifyListeners();
  }

  Future<void> updateNightMode(bool value) async {
    nightMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("nightMode", value);
    notifyListeners();
  }

  Future<void> updateKeepDisplayOn(bool value) async {
    keepDisplayOn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("keepDisplayOn", value);

    if (value) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }

    notifyListeners();
  }

  Future<void> toggleLanguage(String code, bool disabled) async {
    if (disabled) {
      disabledLanguages.add(code);
    } else {
      disabledLanguages.remove(code);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      "disabledLanguages",
      disabledLanguages.toList(),
    );

    notifyListeners();
  }
}
