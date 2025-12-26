import 'package:flutter/material.dart';
import 'package:hymn_app/data/models/language.dart';
import 'package:hymn_app/presentation/widgets/related_hymn_badge.dart';
import 'package:hymn_app/services/language_service.dart';
import 'package:provider/provider.dart';
import 'package:hymn_app/data/models/settings_model.dart';

class HymnHeaderCard extends StatelessWidget {
  final String? title;
  final String? author;
  final String? subTitle;
  final String? meter;
  final String? related;
  final Language? currentLanguage;
  final double? size;

  final VoidCallback? onCopyPressed;
  final VoidCallback? onChordPressed;
  final VoidCallback? onPlayPressed;

  final bool isPlaying;
  final void Function(String hymnId)? onRelatedPressed;
  const HymnHeaderCard({
    super.key,
    this.title,
    this.author,
    this.subTitle,
    this.meter,
    this.related,
    this.size,
    this.onCopyPressed,
    this.onChordPressed,
    this.onPlayPressed,
    required this.isPlaying,
    this.onRelatedPressed,
    this.currentLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------------
            // TITLE + SUBTITLE
            // -------------------------------
            Center(
              child: Column(
                children: [
                  Text(
                    title ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (subTitle != null && subTitle!.isNotEmpty)
                    Text(
                      subTitle!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: size,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            if (author != null && author!.isNotEmpty)
              Text("Author: $author", style: TextStyle(fontSize: size)),

            if (meter != null && meter!.isNotEmpty)
              Text("Meter: $meter", style: TextStyle(fontSize: size)),

            if (related != null && related!.isNotEmpty)
              Builder(
                builder: (context) {
                  final settings = Provider.of<SettingsModel>(context);

                  final relatedBadges = related!
                      .split(',')
                      .map((id) => id.trim())
                      .where((id) => id.isNotEmpty)
                      .map((id) {
                        final lang = LanguageService.detectFromHymnId(id);
                        if (lang == null) return null;

                        // 🔥 FILTER BASED ON SETTINGS
                        if (!settings.relatedEnabledLanguages.contains(
                          lang.badgeText,
                        )) {
                          return null;
                        }

                        return RelatedHymnBadge(
                          language: lang,
                          hymnId: id,
                          onTap: () => onRelatedPressed?.call(id),
                        );
                      })
                      .whereType<Widget>()
                      .toList();

                  // 🚫 Hide section if nothing is allowed
                  if (relatedBadges.isEmpty) return const SizedBox();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        "Related:",
                        style: TextStyle(
                          fontSize: size,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Wrap(spacing: 8, runSpacing: 8, children: relatedBadges),
                    ],
                  );
                },
              ),

            const SizedBox(height: 16),

            // -------------------------------
            // CENTERED ACTION BUTTONS
            // -------------------------------
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: currentLanguage?.badgeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _tabButton(
                    icon: Icons.copy,
                    label: "Copy",
                    onPressed: onCopyPressed,
                  ),
                  const SizedBox(width: 16),
                  _tabButton(
                    icon: isPlaying ? Icons.stop : Icons.play_arrow,
                    label: isPlaying ? "Stop" : "Play",
                    onPressed: onPlayPressed,
                  ),
                  const SizedBox(width: 16),
                  _tabButton(
                    icon: Icons.library_music_rounded,
                    label: "Chords",

                    onPressed: onChordPressed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    Color? backgroundColor,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
