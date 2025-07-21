import 'package:flutter/material.dart';

import 'language_pack.dart';

class LanguagePackListTile extends StatelessWidget {
  final LanguagePack pack;

  const LanguagePackListTile({super.key, required this.pack});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(pack.name),
      subtitle: Text(pack.language.name),
      trailing: Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
