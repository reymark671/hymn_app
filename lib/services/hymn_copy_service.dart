// lib/services/hymn_copy_service.dart
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;

class HymnCopyService {
  static void copyHymn({
    required BuildContext context,
    required Map<String, Object?>? hymn,
    required List<Map<String, Object?>> stanzas,
  }) {
    if (hymn == null) return;

    final buffer = StringBuffer();

    // Header
    buffer.writeln(hymn['main_category'] ?? "");
    if (hymn['sub_category'] != null) buffer.writeln(hymn['sub_category']);
    if (hymn['author'] != null) buffer.writeln("Author: ${hymn['author']}");
    if (hymn['meter'] != null) buffer.writeln("Meter: ${hymn['meter']}");
    buffer.writeln("");

    // Stanzas
    for (var s in stanzas) {
      final no = s['no']?.toString() ?? "";
      String raw = s['text']?.toString() ?? "";

      // Replace <br> with line breaks
      raw = raw.replaceAll("<br>", "\n").replaceAll("<br/>", "\n");

      // Strip remaining HTML
      final plainText = html_parser.parse(raw).body?.text ?? raw;

      if (no.isEmpty || int.tryParse(no) == null) {
        buffer.writeln("Chorus:\n$plainText\n");
      } else {
        buffer.writeln("$no.\n$plainText\n");
      }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Hymn copied to clipboard")),
    );
  }
}
