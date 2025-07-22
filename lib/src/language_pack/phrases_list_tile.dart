import 'package:flutter/material.dart';

import 'firestore_phrase.dart';

class PhrasesListTile extends StatelessWidget {
  final FirestorePhrase phrase;
  final void Function(bool)? onChanged;

  const PhrasesListTile(
      {super.key, required this.phrase, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(phrase.text),
        trailing: Switch.adaptive(
            value: phrase.active,
            onChanged: onChanged,
            activeTrackColor: Colors.greenAccent));
  }
}
