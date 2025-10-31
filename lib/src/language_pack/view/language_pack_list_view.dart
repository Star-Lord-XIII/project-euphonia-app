import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../language_pack_list_tile.dart';
import '../model/language_pack_catalog_model.dart';

class LanguagePackListView extends StatelessWidget {
  const LanguagePackListView({super.key});

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
            FloatingActionButton(child: Icon(Icons.add), onPressed: () {}));
  }
}
