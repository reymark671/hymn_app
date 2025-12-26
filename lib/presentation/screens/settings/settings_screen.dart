import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/settings_model.dart';
import 'package:hymn_app/data/models/language.dart';

class SettingsScreen extends StatelessWidget {

  const SettingsScreen({
     super.key,
   
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Font Size", style: TextStyle(fontSize: 18)),
          Slider(
            value: settings.fontSize,
            min: 12,
            max: 30,
            divisions: 18,
            label: "${settings.fontSize.toInt()}",
            onChanged: (value) => settings.updateFontSize(value),
          ),

          const SizedBox(height: 10),

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

          const SizedBox(height: 20),
          const Text("Disable Languages", style: TextStyle(fontSize: 18)),

          ...allLanguages.map((lang) {
            return CheckboxListTile(
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: lang.badgeColor,
                    child: Text(
                      lang.badgeText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(lang.name), // Show actual language name
                ],
              ),
              value: settings.disabledLanguages.contains(lang.badgeText),
              onChanged: (v) => settings.toggleLanguage(lang.badgeText, v ?? false),
            );
          }).toList(),
        ],
      ),
    );
  }
}
