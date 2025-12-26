import 'package:flutter/material.dart';
import 'package:hymn_app/services/search_service.dart';
import 'package:hymn_app/data/models/language.dart';

class SearchScreen extends StatefulWidget {
  final String currentPrefix;
  const SearchScreen({super.key, required this.currentPrefix});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  TextEditingController searchNumber = TextEditingController();
  TextEditingController searchStanza = TextEditingController();
  TextEditingController searchFirstLine = TextEditingController();

  List<Map<String, Object?>> results = [];
  bool searching = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  Future<void> doSearch(int tabIndex, String query) async {
    setState(() => searching = true);

    List<Map<String, Object?>> res = [];

    if (tabIndex == 0) {
      res = await SearchService.searchByNumber(query, widget.currentPrefix);
    } else {
      res = await SearchService.search(tabIndex, query);
    }

    setState(() {
      results = res;
      searching = false;
    });
  }

  Widget buildBadge(Language lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: lang.badgeColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: lang.borderColor, width: 1),
      ),
      child: Text(
        lang.badgeText,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildResults() {
    if (searching) return const Center(child: CircularProgressIndicator());
    if (results.isEmpty) return const Center(child: Text("No results found"));

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final hymn = results[index];
        final id = hymn["_id"].toString();
        final title = hymn["first_stanza_line"]?.toString() ?? "";

        final lang = SearchService.getLanguageForId(id);

        return ListTile(
          leading: lang != null ? buildBadge(lang) : null,
          title: Text("$id — $title"),
          subtitle: Text(
            hymn["first_chorus_line"]?.toString() ?? "",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => Navigator.pop(context, {"id": id, "lang": lang}),
        );
      },
    );
  }

  Widget buildSearchField(String text, TextEditingController ctrl, int tabIndex) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: text,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (value) => doSearch(tabIndex, value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Hymns"),
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: "Number"),
            Tab(text: "Stanza"),
            Tab(text: "First Line"),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          Column(children: [
            buildSearchField("Search by hymn number…", searchNumber, 0),
            Expanded(child: buildResults())
          ]),
          Column(children: [
            buildSearchField("Search by stanza…", searchStanza, 1),
            Expanded(child: buildResults())
          ]),
          Column(children: [
            buildSearchField("Search by first line…", searchFirstLine, 2),
            Expanded(child: buildResults())
          ]),
        ],
      ),
    );
  }
}
