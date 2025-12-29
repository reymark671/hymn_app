import 'package:flutter/material.dart';
import 'package:hymn_app/data/models/language.dart';

class HymnHeaderCard extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final Language? currentLanguage;
  final double? size;

  final VoidCallback? onCopyPressed;
  final VoidCallback? onFavoritesPress;
  final VoidCallback? onPlayPressed;
  final bool isPlaying;
  final bool isFavorite;

  const HymnHeaderCard({
    super.key,
    this.title,
    this.subTitle,
    this.size,
    this.onCopyPressed,
    this.onFavoritesPress,
    this.onPlayPressed,
    required this.isPlaying,
    this.currentLanguage,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== TITLE =====
            Text(
              title ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size ?? 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (subTitle != null && subTitle!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(subTitle!, textAlign: TextAlign.center),
            ],

            const SizedBox(height: 16),

            // ===== ACTION BUTTONS =====
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color:
                    currentLanguage?.badgeColor ??
                    Theme.of(context).primaryColor,
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
                    icon: Icons.favorite,
                    label: "Favorite",
                    iconColor: isFavorite ? Colors.red : Colors.grey,
                    onPressed: onFavoritesPress,
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
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: iconColor ?? Colors.black87),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
