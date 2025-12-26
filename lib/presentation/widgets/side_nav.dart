import 'package:flutter/material.dart';
import '../../data/models/language.dart';
import 'package:hymn_app/presentation/screens/settings/settings_screen.dart';
import 'package:hymn_app/presentation/screens/about/about_screen.dart';

class SideNav extends StatelessWidget {
  final Function(String route) onItemSelected;
  final Set<String> disabledLanguages;

  const SideNav({
    super.key,
    required this.onItemSelected,
    required this.disabledLanguages,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Languages",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          ...allLanguages
              .where((lang) {
                return !disabledLanguages.contains(lang.badgeText);
              })
              .map((lang) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: lang.badgeColor,
                    child: Text(
                      lang.badgeText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(lang.name),
                  onTap: () {
                    Navigator.pop(context);
                    onItemSelected(lang.badgeText);
                  },
                );
              }),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
