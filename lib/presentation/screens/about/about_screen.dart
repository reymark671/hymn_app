import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("About")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Encouragement to the Saints",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16),

            Text(
              "May the Lord continue to strengthen all the saints who use this app "
              "to pursue Him in songs, hymns, and praises. May every hymn refresh "
              "your spirit, uplift your heart, and deepen your enjoyment of Christ "
              "day by day.\n\n"
              "If you feel burdened to partake in the development of apps that support "
              "the saints in their spiritual pursuit, you are warmly invited to contact "
              "me. Whether you desire to help in development, contribute ideas, or offer "
              "for this kind of service unto the Lord, your portion is valued.\n\n"
              "📩 Email: dev.reymark.egot@gmail.com",
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),

            SizedBox(height: 30),

            Text(
              "Grace be with you all.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
