import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class SystemMidiPlayer {
  static const _channel = MethodChannel('system_midi');

  static Future<String> _copyAsset(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${assetPath.split('/').last}');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.path;
  }

  static Future<void> play(String assetPath) async {
    final path = await _copyAsset(assetPath);
    await _channel.invokeMethod('play', {'path': path});
  }

  static Future<void> stop() async {
    await _channel.invokeMethod('stop');
  }
}
