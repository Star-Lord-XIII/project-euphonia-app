import 'package:flutter/material.dart';

import 'firestore_phrase.dart';

class PhrasesListTile extends StatelessWidget {
  final FirestorePhrase phrase;

  const PhrasesListTile({super.key, required this.phrase});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(phrase.text),
      trailing: Icon(Icons.circle,
          color: phrase.active ? Colors.greenAccent : Colors.redAccent),
      onTap: () {},
    );
  }
}
