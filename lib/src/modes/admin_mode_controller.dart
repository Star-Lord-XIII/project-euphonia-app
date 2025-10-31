import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/result.dart';
import '../language_pack/model/language_pack_catalog_model.dart';
import '../language_pack/model/language_pack_summary.dart';
import '../language_pack/repository/language_pack_repo.dart';
import '../language_pack/view/language_pack_list_view.dart';

class AdminModeController extends StatefulWidget {
  const AdminModeController({super.key});

  @override
  State<AdminModeController> createState() => _AdminModeControllerState();
}

class _AdminModeControllerState extends State<AdminModeController> {

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
    return ListView(children: [
          ListTile(
              title: Text("Manage phrase packs",
                  style: Theme.of(context).textTheme.headlineSmall),
              subtitle: Text(
                  'Add or update phrases for various languages, scenarios and media'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguagePackListView(),
                  ),
                );
              })
        ]);
  }
}
