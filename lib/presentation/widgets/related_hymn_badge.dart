import 'package:flutter/material.dart';
import 'package:hymn_app/data/models/language.dart';

class RelatedHymnBadge extends StatelessWidget {
  final Language language;
  final String hymnId;
  final VoidCallback onTap;

  const RelatedHymnBadge({
    super.key,
    required this.language,
    required this.hymnId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final number = hymnId.replaceFirst(
      RegExp('^${language.prefixes.join('|')}'),
      '',
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: language.badgeColor.withOpacity(0.15),
          border: Border.all(color: language.borderColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 10,
              backgroundColor: language.badgeColor,
              child: Text(
                language.badgeText,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              number,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
