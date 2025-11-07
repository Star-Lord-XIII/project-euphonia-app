import 'package:flutter/material.dart';

import 'model/language_pack_summary.dart';
import 'phrases_list_controller.dart';

class LanguagePackListTile extends StatelessWidget {
  final LanguagePackSummary pack;

  const LanguagePackListTile(
      {super.key,  required this.pack});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(pack.name),
      subtitle: Text(pack.language.name),
      trailing: Wrap(
          runAlignment: WrapAlignment.center,
          alignment: WrapAlignment.center,
          children: [
            Chip(label: Text('${pack.phrasesCount}')),
            Padding(
                padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
                child: Icon(Icons.chevron_right))
          ]),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PhrasesListController(documentPath: pack.languagePackCode)));
      },
    );
  }
}
