// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:hymn_app/presentation/widgets/side_nav.dart';
import 'package:hymn_app/presentation/widgets/hymn_header_card.dart';
import 'package:hymn_app/presentation/screens/search/search_screen.dart';
import 'package:hymn_app/presentation/screens/settings/settings_screen.dart';
import 'package:hymn_app/presentation/widgets/stanza_block.dart';

import 'package:hymn_app/data/models/language.dart';
import 'package:hymn_app/data/models/settings_model.dart';

import 'package:hymn_app/services/hymn_loader.dart';
import 'package:hymn_app/services/hymn_state.dart';
import 'package:hymn_app/services/swipe_handler.dart';
import 'package:hymn_app/services/language_service.dart';
import 'package:hymn_app/services/hymn_copy_service.dart';
import 'package:hymn_app/services/chord_service.dart';
import 'package:hymn_app/services/midi_player_service.dart';
import 'package:hymn_app/presentation/screens/chords/guitar_chord.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);

    return MaterialApp(
      title: 'Psalmist of the Lord',
      themeMode: settings.nightMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: "Psalmist of the Lord"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, Object?>? hymn;
  List<Map<String, Object?>> stanzas = [];

  bool loading = true;
  bool isPlaying = false;

  Language? currentLanguage;

  @override
  void initState() {
    super.initState();
    _restoreLastState();
  }

  Future<void> _stopMidiIfPlaying() async {
    if (isPlaying) {
      await SystemMidiPlayer.stop();
      setState(() => isPlaying = false);
    }
  }

  Future<void> _restoreLastState() async {
    final saved = await HymnState.load();
    final lastId = saved["id"];
    final lastLang = saved["lang"];

    if (lastId != null && lastLang != null) {
      currentLanguage = LanguageService.getByCode(lastLang);
      await _loadHymnById(lastId);
    } else {
      currentLanguage = LanguageService.getByCode("E");
      await _loadHymnByPrefix("E");
    }
  }

  Future<void> _loadHymnByPrefix(String prefix) async {
    setState(() => loading = true);

    final row = await HymnLoader.loadByPrefix(prefix);

    if (row == null) {
      setState(() {
        hymn = null;
        stanzas = [];
        loading = false;
      });
      return;
    }

    final stanzaRows = await HymnLoader.loadStanzas(row['_id'].toString());

    setState(() {
      hymn = row;
      stanzas = stanzaRows;
      loading = false;
    });

    HymnState.save(row['_id'].toString(), prefix);
  }

  Future<void> _loadHymnById(String id) async {
    setState(() => loading = true);

    final row = await HymnLoader.loadById(id);

    if (row == null) {
      setState(() {
        hymn = null;
        stanzas = [];
        loading = false;
      });
      return;
    }

    final stanzaRows = await HymnLoader.loadStanzas(id);

    setState(() {
      hymn = row;
      stanzas = stanzaRows;
      loading = false;
    });

    HymnState.save(id, currentLanguage?.badgeText ?? "E");
  }

  Future<void> _loadNextHymn() async {
    await _stopMidiIfPlaying();
    if (hymn == null) return;
    final prefix = currentLanguage?.prefixes.first ?? "";
    final currentNo = int.tryParse(hymn?['no'].toString() ?? "") ?? 0;

    final nextId = await SwipeHandler.next(prefix, currentNo);
    if (nextId != null) await _loadHymnById(nextId);
  }

  Future<void> _loadPreviousHymn() async {
    await _stopMidiIfPlaying();
    if (hymn == null) return;
    final prefix = currentLanguage?.prefixes.first ?? "";
    final currentNo = int.tryParse(hymn?['no'].toString() ?? "") ?? 0;

    final prevId = await SwipeHandler.previous(prefix, currentNo);
    if (prevId != null) await _loadHymnById(prevId);
  }

  Future<void> _openSearchScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SearchScreen(currentPrefix: currentLanguage?.prefixes.first ?? "E"),
      ),
    );

    if (result != null && result is Map) {
      final selectedId = result["id"] as String?;
      final lang = result["lang"] as Language?;

      if (lang != null) {
        setState(() => currentLanguage = lang);
      }

      if (selectedId != null) {
        await _loadHymnById(selectedId);
      }
    }
  }

  void _handleNav(String route) async {
    final lang = LanguageService.getByCode(route);

    setState(() => currentLanguage = lang);

    final lastId = await HymnState.loadLastForLanguage(lang.badgeText);

    if (lastId != null) {
      await _loadHymnById(lastId);
    } else {
      await _loadHymnByPrefix(route);
    }
  }

  void _showNoChordsSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("No chords available for ${hymn!['_id']}")),
    );
  }

  Future<void> _openChordScreen(String svgPath) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ChordFullscreenPage(
          hymnId: hymn!['_id'].toString(),
          svgPath: svgPath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: currentLanguage?.badgeColor ?? Colors.deepPurple,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:
              currentLanguage?.badgeColor ?? Theme.of(context).primaryColor,
          title: Text(hymn?['_id']?.toString() ?? widget.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _openSearchScreen,
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),

        drawer: SideNav(
          onItemSelected: _handleNav,
          disabledLanguages: settings.disabledLanguages,
        ),

        body: loading
            ? const Center(child: CircularProgressIndicator())
            : hymn == null
            ? const Center(child: Text("No hymn found"))
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;

        if (details.primaryVelocity! < 0) {
          _loadNextHymn();
        } else if (details.primaryVelocity! > 0) {
          _loadPreviousHymn();
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          HymnHeaderCard(
            title:
                hymn?['main_category']?.toString() ??
                hymn?['first_stanza_line']?.toString(),
            subTitle: hymn?['sub_category']?.toString(),
            author: hymn?['author']?.toString(),
            meter: hymn?['meter']?.toString(),
            related: hymn?['related']?.toString(),
            size: 20,
            currentLanguage: currentLanguage,

            isPlaying: isPlaying,

            onCopyPressed: () {
              HymnCopyService.copyHymn(
                context: context,
                hymn: hymn,
                stanzas: stanzas,
              );
            },

            onChordPressed: () async {
              if (hymn == null) return;

              final svgPath = await ChordService.getChordSvgPath(hymn: hymn!);

              if (!mounted) return;

              if (svgPath == null) {
                _showNoChordsSnackBar();
                return;
              }

              _openChordScreen(svgPath);
            },
            onPlayPressed: () async {
              final tune = hymn?['tune'];
              if (tune == null) return;

              if (isPlaying) {
                await SystemMidiPlayer.stop();
                setState(() => isPlaying = false);
              } else {
                await SystemMidiPlayer.play('assets/tune/m$tune.mid');
                setState(() => isPlaying = true);
              }
            },
            onRelatedPressed: (relatedId) async {
              await _stopMidiIfPlaying();
              final lang = LanguageService.detectFromHymnId(relatedId);
              if (lang != null) {
                setState(() {
                  currentLanguage = lang;
                });
              }
              await _loadHymnById(relatedId);
            },
          ),

          const SizedBox(height: 24),

          ...stanzas.map((s) {
            return StanzaBlock(stanza: s, currentLanguage: currentLanguage);
          }),
        ],
      ),
    );
  }
}
