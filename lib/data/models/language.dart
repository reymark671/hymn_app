import 'package:flutter/material.dart';

class Language {
  final String name;
  final List<String> prefixes;
  final Color badgeColor;
  final Color borderColor;
  final String badgeText;

  const Language({
    required this.name,
    required this.prefixes,
    required this.badgeColor,
    required this.borderColor,
    required this.badgeText,
  });
}

// ---------------------------------------------
// ADD ALL LANGUAGES HERE (shared everywhere)
// ---------------------------------------------

const List<Language> allLanguages = [
  Language(name: 'English', prefixes: ['E'], badgeColor: Color.fromARGB(255, 39, 94, 156), borderColor: Color(0xFF616161), badgeText: 'E'),
  Language(name: 'Tagalog', prefixes: ['T'], badgeColor: Color(0xFF4DB6AC), borderColor: Color(0xFF00796B), badgeText: 'T'),
  Language(name: 'Cebuano', prefixes: ['CB'], badgeColor: Color(0xFFFFC107), borderColor: Color(0xFFFFA000), badgeText: 'CB'),
  Language(name: 'Be Filled', prefixes: ['BF'], badgeColor: Color.fromARGB(255, 3, 216, 244), borderColor: Color(0xFF00ACC1), badgeText: 'BF'),
  Language(name: 'New Songs', prefixes: ['NS'], badgeColor: Color.fromARGB(255, 239, 56, 0), borderColor: Color(0xFFEF6C00), badgeText: 'NS'),
  Language(name: 'Children', prefixes: ['Ch'], badgeColor: Color(0xFFDCE775), borderColor: Color(0xFFC0CA33), badgeText: 'Ch'),
  Language(name: '中文-繁', prefixes: ['C'], badgeColor: Color(0xFF7CB342), borderColor: Color(0xFF558B2F), badgeText: 'C'),
  Language(name: '補充本-繁', prefixes: ['CS'], badgeColor: Color(0xFF81C784), borderColor: Color(0xFF4CAF50), badgeText: 'CS'),
  Language(name: '中文-简', prefixes: ['Z'], badgeColor: Color(0xFF4FC3F7), borderColor: Color(0xFF0288D1), badgeText: 'Z'),
  Language(name: '補充本-简', prefixes: ['ZS'], badgeColor: Color(0xFFBA68C8), borderColor: Color(0xFF8E24AA), badgeText: 'ZS'),
  Language(name: 'French', prefixes: ['FR', 'F'], badgeColor: Color(0xFFEC407A), borderColor: Color(0xFFD81B60), badgeText: 'FR'),
  Language(name: 'Spanish', prefixes: ['S'], badgeColor: Color(0xFF64B5F6), borderColor: Color(0xFF1976D2), badgeText: 'S'),
  Language(name: 'India', prefixes: ['I'], badgeColor: Color.fromARGB(255, 220, 11, 186), borderColor: Color(0xFF1976D2), badgeText: 'I'),
  Language(name: 'Korean', prefixes: ['K'], badgeColor: Color(0xFF8D6E63), borderColor: Color(0xFF6D4C41), badgeText: 'K'),
  Language(name: 'German', prefixes: ['G'], badgeColor: Color(0xFFFF8A65), borderColor: Color(0xFFD84315), badgeText: 'G'),
  Language(name: 'Japanese', prefixes: ['J'], badgeColor: Color(0xFF4DB6AC), borderColor: Color(0xFF00796B), badgeText: 'J'),
  Language(name: 'Farsi', prefixes: ['F'], badgeColor: Color(0xFF9575CD), borderColor: Color(0xFF673AB7), badgeText: 'F'),
  Language(name: 'Slovak', prefixes: ['SK'], badgeColor: Color(0xFFBA68C8), borderColor: Color(0xFF8E24AA), badgeText: 'SK'),
];
