import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("About"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.library_music_rounded,
                    size: 48,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Encouragement to the Saints",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // MAIN MESSAGE
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "May the Lord continue to strengthen all the saints who use this app "
                  "to pursue Him in songs, hymns, and praises. May every hymn refresh "
                  "your spirit, uplift your heart, and deepen your enjoyment of Christ "
                  "day by day.\n\n"
                  "If you feel burdened to partake in the development of apps that support "
                  "the saints in their spiritual pursuit, you are warmly invited to reach out. "
                  "Whether through development, ideas, or offerings for this kind of service "
                  "unto the Lord, every portion is valued.",
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BETA NOTICE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "This app is currently in BETA and under active testing. "
                      "Please bear with us as improvements and refinements are ongoing.\n\n"
                      "If you encounter any issues or bugs, we would greatly appreciate "
                      "your help by reporting them via email.",
                      style: TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CONTACT
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.email_outlined),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "dev.reymark.egot@gmail.com",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // FOOTER
            Center(
              child: Text(
                "Grace be with you all.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
