import 'dart:core';

import 'package:flutter/material.dart';

import '../language_pack/view/language_pack_list_view.dart';

class AdminModeController extends StatefulWidget {
  const AdminModeController({super.key});

  @override
  State<AdminModeController> createState() => _AdminModeControllerState();
}

class _AdminModeControllerState extends State<AdminModeController> {
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
