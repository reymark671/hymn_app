import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hymn_app/data/models/language.dart';
import 'package:hymn_app/data/models/settings_model.dart';
import 'package:provider/provider.dart';

class StanzaBlock extends StatelessWidget {
  final Map<String, Object?> stanza;
  final Language? currentLanguage;

  const StanzaBlock({
    super.key,
    required this.stanza,
    required this.currentLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);

    final no = stanza['no']?.toString() ?? "";
    final isChorus = no.isEmpty || int.tryParse(no) == null;
    final text = stanza['text']?.toString() ?? "";

    // --------- CHORUS LAYOUT ----------
    if (isChorus) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Chorus",
              style: TextStyle(
                fontSize: settings.fontSize,
                fontWeight: FontWeight.bold,
                color: currentLanguage?.badgeColor ?? Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Html(
              data: text,
              style: {
                "body": Style(
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                  color: currentLanguage?.badgeColor ?? Colors.deepPurple,
                  fontSize: FontSize(settings.fontSize),
                  lineHeight: const LineHeight(1.5),
                ),
              },
            ),
          ],
        ),
      );
    }

    // --------- NORMAL VERSE LAYOUT ----------
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$no.",
            style: TextStyle(
              fontSize: settings.fontSize,
              fontWeight: FontWeight.bold,
              color: currentLanguage?.badgeColor ?? Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 8),
          Html(
            data: text,
            style: {
              "body": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(settings.fontSize),
                lineHeight: const LineHeight(1.5),
              ),
            },
          ),
        ],
      ),
    );
  }
}
