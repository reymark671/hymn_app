import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    // Get app documents directory
    Directory docsDir = await getApplicationDocumentsDirectory();
    String dbPath = join(docsDir.path, "hymns.db");

    // If DB does NOT exist, copy from assets
    if (!await File(dbPath).exists()) {
      ByteData data = await rootBundle.load("assets/db/hymns.db");
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(dbPath).writeAsBytes(bytes);
    }

    // Open the database
    return await openDatabase(dbPath);
  }
}
