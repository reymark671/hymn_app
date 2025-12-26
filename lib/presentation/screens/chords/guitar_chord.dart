import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChordFullscreenPage extends StatelessWidget {
  final String hymnId;
  final String svgPath;

  const ChordFullscreenPage({
    super.key,
    required this.hymnId,
    required this.svgPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 253, 253),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 248, 245, 245),
        title: Text(hymnId),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: FutureBuilder(
        future: rootBundle.load(svgPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color.fromARGB(255, 24, 208, 141)),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error loading chord sheet.",
                style: TextStyle(color: Color.fromARGB(255, 255, 0, 0)),
              ),
            );
          }

          return SizedBox.expand(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 8.0,
              clipBehavior: Clip.none,

              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,

                  child: SvgPicture.asset(
                    svgPath,

                    // Let SVG determine size naturally + allow scaling
                    width: MediaQuery.of(context).size.width * 1.5,
                    height: MediaQuery.of(context).size.height * 1.5,

                    fit: BoxFit.contain,
                    allowDrawingOutsideViewBox: true,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
