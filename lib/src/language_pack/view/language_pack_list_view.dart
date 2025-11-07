import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/result.dart';
import '../language_pack_list_tile.dart';
import '../model/language_pack_catalog_model.dart';
import '../model/language_pack_summary.dart';
import '../repository/language_pack_repo.dart';

class LanguagePackListView extends StatefulWidget {
  const LanguagePackListView({super.key});

  @override
  State<LanguagePackListView> createState() => _LanguagePackListViewState();
}

class _LanguagePackListViewState extends State<LanguagePackListView> {

  @override
  void initState() {
    LanguagePackRepository repo = context.read();
    LanguagePackCatalogModel model = context.read();
    repo.getLanguagePackSummaryList().then((Result<List> languagePackListResult) {
      List<dynamic> fetchedResults = [];
      switch (languagePackListResult) {
        case Ok<List>():
          fetchedResults = languagePackListResult.value;
          break;
        case Error<void>():
          break;
      }
      List<LanguagePackSummary> mappedList = fetchedResults
          .map((x) => LanguagePackSummary(
          version: x.version,
          name: x.name,
          language: x.language,
          languagePackCode: x.languagePackCode,
          phrasesCount: x.phrasesCount))
          .toList();
      model.updateLanguagePackSummaryList(List<LanguagePackSummary>.from(mappedList));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final languagePackCatalog =
        Provider.of<LanguagePackCatalogModel>(context, listen: true);
    return Scaffold(
        body: CustomScrollView(slivers: [
          SliverAppBar(
              pinned: true,
              flexibleSpace:
                  AppBar(centerTitle: false, title: Text('Language Packs'))),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                (context, index) => LanguagePackListTile(
                    pack: languagePackCatalog.languagePackSummaryList[index]),
                childCount: languagePackCatalog.languagePackSummaryList.length),
          ),
          SliverPadding(padding: EdgeInsets.symmetric(vertical: 16)),
          SliverToBoxAdapter(child: SizedBox(height: 100))
        ]),
        floatingActionButton:
            FloatingActionButton(child: Icon(Icons.add), onPressed: () {
              print("ADD A NEW LANGUAGE PACK");
            }));
  }
}
