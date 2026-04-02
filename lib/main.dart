// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:hymn_app/services/favorites_service.dart';

import 'package:hymn_app/presentation/widgets/side_nav.dart';
import 'package:hymn_app/presentation/widgets/hymn_header_card.dart';
import 'package:hymn_app/presentation/screens/search/search_screen.dart';
import 'package:hymn_app/presentation/screens/settings/settings_screen.dart';
import 'package:hymn_app/presentation/widgets/stanza_block.dart';

import 'package:hymn_app/data/models/language.dart';
import 'package:hymn_app/data/models/settings_model.dart';
import 'package:hymn_app/presentation/widgets/related_hymn_badge.dart';

import 'package:hymn_app/services/hymn_loader.dart';
import 'package:hymn_app/services/hymn_state.dart';
import 'package:hymn_app/services/swipe_handler.dart';
import 'package:hymn_app/services/language_service.dart';
import 'package:hymn_app/services/hymn_copy_service.dart';
import 'package:hymn_app/services/midi_player_service.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

// 🔥 DATABASE VERSION CONTROL
const int APP_DB_VERSION = 2; // ⬅️ increment when DB schema changes
const String DB_NAME = "hymns.db";

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
      debugShowCheckedModeBanner: false,

      themeMode: settings.nightMode ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
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

enum HymnViewMode { text, chords, piano, guitar }

class ZoomableSvgViewer extends StatefulWidget {
  final String svgPath;
  final String title;
  final Color? svgColor;

  const ZoomableSvgViewer({
    super.key,
    required this.svgPath,
    required this.title,
    this.svgColor,
  });

  @override
  State<ZoomableSvgViewer> createState() => _ZoomableSvgViewerState();
}

class SvgFullscreenPage extends StatelessWidget {
  final String svgPath;
  final String title;

  const SvgFullscreenPage({
    super.key,
    required this.svgPath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return InteractiveViewer(
              minScale: 0.5,
              maxScale: 6,
              panEnabled: true,
              scaleEnabled: true,
              constrained: false,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxWidth * 1.9,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                  child: SvgPicture.asset(
                    svgPath,
                    allowDrawingOutsideViewBox: true,

                    // 🌙 DARK MODE FIX
                    colorFilter: isDark
                        ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                        : null,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

double _calculateRelatedHeaderHeight(BuildContext context, int count) {
  // Badge height ≈ 36
  // Vertical padding + title ≈ 44
  // Items per row ≈ 4 (phone)

  final itemsPerRow = 4;
  final rows = (count / itemsPerRow).ceil();

  return 44 + (rows * 40);
}

class _ZoomableSvgViewerState extends State<ZoomableSvgViewer> {
  final TransformationController _controller = TransformationController();
  bool _initialized = false;

  // 🔥 Smaller base = BIGGER default zoom
  static const double _svgBaseWidth = 120;

  void _zoom(double factor) {
    final currentScale = _controller.value.getMaxScaleOnAxis();
    final newScale = (currentScale * factor).clamp(2.0, 14.0);

    _controller.value = Matrix4.identity()..scale(newScale, newScale);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_initialized) {
          final screenWidth = constraints.maxWidth;

          // 🚀 VERY aggressive initial zoom
          final initialScale = (screenWidth / _svgBaseWidth).clamp(4.0, 7.5);

          _controller.value = Matrix4.identity()
            ..scale(initialScale, initialScale);

          _initialized = true;
        }

        return Container(
          color: Theme.of(context).colorScheme.surface,
          height: MediaQuery.of(context).size.height * 2.5,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: _controller,
                  minScale: 2,
                  maxScale: 14,
                  panEnabled: true,
                  scaleEnabled: true,
                  constrained: false,
                  child: SvgPicture.asset(
                    widget.svgPath,
                    fit: BoxFit.none,
                    alignment: Alignment.topCenter,
                    allowDrawingOutsideViewBox: true,
                    colorFilter: widget.svgColor != null
                        ? ColorFilter.mode(widget.svgColor!, BlendMode.srcIn)
                        : null,
                  ),
                ),
              ),

              // ===== CONTROLS =====
              Positioned(
                right: 12,
                top: 12,
                child: Column(
                  children: [
                    _overlayButton(
                      icon: Icons.zoom_in,
                      onTap: () => _zoom(1.25),
                    ),
                    const SizedBox(height: 8),
                    _overlayButton(
                      icon: Icons.zoom_out,
                      onTap: () => _zoom(0.8),
                    ),
                    const SizedBox(height: 8),
                    _overlayButton(
                      icon: Icons.fullscreen,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            fullscreenDialog: true,
                            builder: (_) => SvgFullscreenPage(
                              svgPath: widget.svgPath,
                              title: widget.title,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _overlayButton({required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface.withOpacity(0.85),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: theme.colorScheme.onSurface, size: 22),
        ),
      ),
    );
  }
}

class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  StickyHeaderDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      elevation: overlapsContent ? 3 : 0,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant StickyHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

class StickyRelatedBar extends StatelessWidget {
  final List<String> relatedIds;
  final void Function(String hymnId)? onRelatedPressed;

  const StickyRelatedBar({
    super.key,
    required this.relatedIds,
    this.onRelatedPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (relatedIds.isEmpty) return const SizedBox();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final badges = relatedIds.map((id) {
      final lang = LanguageService.detectFromHymnId(id)!;

      return RelatedHymnBadge(
        language: lang,
        hymnId: id,
        onTap: () => onRelatedPressed?.call(id),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

      // 🔥 FORCE DARK MODE LOOK
      color: isDark ? const Color(0xFF121212) : theme.colorScheme.surface,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Related:",
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: badges),
        ],
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, Object?>? hymn;
  List<Map<String, Object?>> stanzas = [];
  List<String> _getFilteredRelatedIds(BuildContext context) {
    if (hymn == null) return [];

    final relatedRaw = hymn!['related']?.toString();
    if (relatedRaw == null || relatedRaw.isEmpty) return [];

    final settings = Provider.of<SettingsModel>(context, listen: false);

    final relatedIds = relatedRaw
        .split(',')
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty);

    // 🔥 IMPORTANT FIX
    // If user has not selected any related languages,
    // show ALL related hymns
    if (settings.relatedEnabledLanguages.isEmpty) {
      return relatedIds.toList();
    }

    // Otherwise, filter by selected languages
    return relatedIds.where((id) {
      final lang = LanguageService.detectFromHymnId(id);
      if (lang == null) return false;

      return settings.relatedEnabledLanguages.contains(lang.badgeText);
    }).toList();
  }

  HymnViewMode viewMode = HymnViewMode.text;
  bool loading = true;
  bool isPlaying = false;
  bool isFavorite = false;

  Language? currentLanguage;

  @override
  void initState() {
    super.initState();
    _restoreLastState();
    _checkForUpdate();
    ensureLatestDatabase();
  }

  Future<void> _stopMidiIfPlaying() async {
    if (isPlaying) {
      await SystemMidiPlayer.stop();
      setState(() => isPlaying = false);
    }
  }

  Future<void> ensureLatestDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVersion = prefs.getInt('db_version') ?? 0;

    if (savedVersion < APP_DB_VERSION) {
      final dbPath = p.join(await getDatabasesPath(), DB_NAME);

      // 🔥 Delete old DB so new one is copied from assets
      await deleteDatabase(dbPath);

      await prefs.setInt('db_version', APP_DB_VERSION);
    }
  }

  Future<void> _checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (e) {
      // silently ignore or log
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
    final fav = await FavoritesService.isFavorite(id);
    if (!mounted) return;

    setState(() {
      isFavorite = fav;
    });
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

  Future<bool> assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      return false;
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

  Widget _buildViewContent() {
    switch (viewMode) {
      case HymnViewMode.text:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HYMN TEXT =====
            ...stanzas.map((s) {
              return StanzaBlock(stanza: s, currentLanguage: currentLanguage);
            }),

            const SizedBox(height: 24),

            // ===== AUTHOR & METER (BOTTOM) =====
            if (hymn != null) ...[
              const Divider(),
              const SizedBox(height: 8),

              Text(
                "Author: ${hymn?['author'] ?? 'Unknown'}",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "Meter: ${hymn?['meter'] ?? '—'}",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        );

      case HymnViewMode.chords:
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              "Chords view coming soon",
              style: TextStyle(fontSize: 16),
            ),
          ),
        );

      case HymnViewMode.piano:
        return _buildPianoView();

      case HymnViewMode.guitar:
        return _buildGuitarView();
    }
  }

  Widget _buildGuitarView() {
    final hymnId = hymn?['_id']?.toString();
    if (hymnId == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          "No hymn selected",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final svgPath = "assets/guitarSvg/$hymnId.svg";

    return FutureBuilder<bool>(
      future: assetExists(svgPath),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data == false) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "No guitar chords available",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return ZoomableSvgViewer(
          svgPath: svgPath,
          title: "Guitar",
          svgColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : null, // keep original in light mode
        );
      },
    );
  }

  Widget _buildPianoView() {
    final hymnId = hymn?['_id']?.toString();
    if (hymnId == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          "No hymn selected",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final svgPath = "assets/pianoSvg/$hymnId.svg";

    return FutureBuilder<bool>(
      future: assetExists(svgPath),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data == false) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "No piano notation available",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        return ZoomableSvgViewer(
          svgPath: svgPath,
          title: "Piano",
          svgColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : null,
        );
      },
    );
  }

  Widget _buildViewModeSelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: ToggleButtons(
        isSelected: [
          viewMode == HymnViewMode.text,
          viewMode == HymnViewMode.chords,
          viewMode == HymnViewMode.piano,
          viewMode == HymnViewMode.guitar,
        ],

        onPressed: (index) async {
          await _stopMidiIfPlaying();
          setState(() {
            viewMode = HymnViewMode.values[index];
          });
        },

        borderRadius: BorderRadius.circular(8),
        constraints: const BoxConstraints(minHeight: 36, minWidth: 80),

        // 🌙 DARK MODE SAFE COLORS
        fillColor: colorScheme.primaryContainer,
        selectedColor: colorScheme.onPrimaryContainer,
        color: colorScheme.onSurface,
        borderColor: colorScheme.outline,
        selectedBorderColor: colorScheme.primary,

        children: const [
          Text("Text"),
          Text("Chords"),
          Text("Piano"),
          Text("Guitar"),
        ],
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
    final filteredRelated = _getFilteredRelatedIds(context);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity;
        if (velocity == null) return;

        // 👉 swipe left → next hymn
        if (velocity < -200) {
          _loadNextHymn();
        }

        // 👈 swipe right → previous hymn
        if (velocity > 200) {
          _loadPreviousHymn();
        }
      },

      child: CustomScrollView(
        slivers: [
          // =========================
          // TITLE + SUBTITLE
          // =========================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: HymnHeaderCard(
                title:
                    hymn?['main_category']?.toString() ??
                    hymn?['first_stanza_line']?.toString(),
                subTitle: hymn?['sub_category']?.toString(),
                size: 20,
                currentLanguage: currentLanguage,
                isPlaying: isPlaying,
                isFavorite: isFavorite,
                onCopyPressed: () {
                  HymnCopyService.copyHymn(
                    context: context,
                    hymn: hymn,
                    stanzas: stanzas,
                  );
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
                onFavoritesPress: () async {
                  if (hymn == null) return;

                  final hymnId = hymn!['_id'].toString();
                  await FavoritesService.toggleFavorite(hymnId);
                  final fav = await FavoritesService.isFavorite(hymnId);

                  if (!mounted) return;
                  setState(() => isFavorite = fav);
                },
              ),
            ),
          ),

          // =========================
          // STICKY RELATED
          // =========================
          if (filteredRelated.isNotEmpty)
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyHeaderDelegate(
                height: _calculateRelatedHeaderHeight(
                  context,
                  filteredRelated.length,
                ),
                child: StickyRelatedBar(
                  relatedIds: filteredRelated,
                  onRelatedPressed: (id) async {
                    await _stopMidiIfPlaying();
                    final lang = LanguageService.detectFromHymnId(id);
                    if (lang != null) setState(() => currentLanguage = lang);
                    await _loadHymnById(id);
                  },
                ),
              ),
            ),
          // =========================
          // VIEW MODE SELECTOR
          // =========================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _buildViewModeSelector(),
            ),
          ),

          // =========================
          // MAIN CONTENT
          // =========================
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Card(
                color: Theme.of(context).colorScheme.surface,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildViewContent(),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
