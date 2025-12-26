import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hymn_app/data/models/settings_model.dart';
import 'package:hymn_app/data/models/language.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // -----------------------------
          // FONT SIZE
          // -----------------------------
          const Text("Font Size", style: TextStyle(fontSize: 18)),
          Slider(
            value: settings.fontSize,
            min: 12,
            max: 80,
            divisions: 18,
            label: "${settings.fontSize.toInt()}",
            onChanged: settings.updateFontSize,
          ),

          const SizedBox(height: 10),

          // -----------------------------
          // TOGGLES
          // -----------------------------
          SwitchListTile(
            title: const Text("Night Mode"),
            value: settings.nightMode,
            onChanged: settings.updateNightMode,
          ),

          SwitchListTile(
            title: const Text("Keep Display On"),
            subtitle: const Text("Prevent screen from sleeping"),
            value: settings.keepDisplayOn,
            onChanged: settings.updateKeepDisplayOn,
          ),

          const Divider(height: 32),

          // -----------------------------
          // DISABLE LANGUAGES
          // -----------------------------
          const Text(
            "Disable Languages",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          ...allLanguages.map((lang) {
            return CheckboxListTile(
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: lang.badgeColor,
                    child: Text(
                      lang.badgeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(lang.name),
                ],
              ),
              value: settings.disabledLanguages.contains(lang.badgeText),
              onChanged: (v) =>
                  settings.toggleLanguage(lang.badgeText, v ?? false),
            );
          }),

          const Divider(height: 32),

          // -----------------------------
          // RELATED HYMNS FILTER
          // -----------------------------
          const Text(
            "Related Hymns Languages",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Only show related hymns from selected languages",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),

          ...allLanguages.map((lang) {
            return CheckboxListTile(
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: lang.badgeColor,
                    child: Text(
                      lang.badgeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(lang.name),
                ],
              ),
              value: settings.relatedEnabledLanguages.contains(lang.badgeText),
              onChanged: (v) =>
                  settings.toggleRelatedLanguage(lang.badgeText, v ?? false),
            );
          }),
        ],
      ),
    );
  }
}
