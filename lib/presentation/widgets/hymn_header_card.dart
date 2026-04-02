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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                color: isDark ? Colors.white : Colors.black,
              ),
            ),

            if (subTitle != null && subTitle!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                subTitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // ===== ACTION BUTTONS =====
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2A2A2A)
                    : theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _tabButton(context, Icons.copy, "Copy", onCopyPressed),
                  const SizedBox(width: 16),
                  _tabButton(
                    context,
                    isPlaying ? Icons.stop : Icons.play_arrow,
                    isPlaying ? "Stop" : "Play",
                    onPlayPressed,
                  ),
                  const SizedBox(width: 16),
                  _tabButton(
                    context,
                    Icons.favorite,
                    "Favorite",
                    onFavoritesPress,
                    iconColor: isFavorite ? Colors.red : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback? onPressed, {
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3A3A3A) : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 16,
              color: iconColor ?? (isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
