import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'language_pack.dart';
import 'phrases_list_controller.dart';

class LanguagePackListTile extends StatelessWidget {
  final DocumentReference<LanguagePack> packReference;
  final LanguagePack pack;

  const LanguagePackListTile(
      {super.key, required this.packReference, required this.pack});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(pack.name),
      subtitle: Text(pack.language.name),
      trailing: Wrap(
          runAlignment: WrapAlignment.center,
          alignment: WrapAlignment.center,
          children: [
            Chip(label: Text('${pack.phrases.length}')),
            Padding(
                padding: EdgeInsets.fromLTRB(0, 12, 0, 0),
                child: Icon(Icons.chevron_right))
          ]),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PhrasesListController(reference: packReference)),
        );
      },
    );
  }
}
