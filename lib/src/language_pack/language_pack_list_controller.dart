import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sealed_languages/sealed_languages.dart';

import 'language_pack.dart';
import 'language_pack_list_tile.dart';

class LanguagePackListController extends StatefulWidget {
  const LanguagePackListController({super.key});

  @override
  State<LanguagePackListController> createState() =>
      _LanguagePackListControllerState();
}

class _LanguagePackListControllerState
    extends State<LanguagePackListController> {
  NaturalLanguage? _selectedLanguage;
  final TextEditingController _languageFilterController =
      TextEditingController();
  final TextEditingController _nameFieldController = TextEditingController();
  final TextEditingController _codeFieldController = TextEditingController();
  CollectionReference<LanguagePack>? languagePackRef;
  String _warningMessage = '';
  String _languagePackCode = '';

  @override
  void initState() {
    super.initState();
    languagePackRef = FirebaseFirestore.instance
        .collection('language_packs')
        .withConverter<LanguagePack>(
          fromFirestore: (snapshots, _) =>
              LanguagePack.fromJson(snapshots.data()!),
          toFirestore: (languagePack, _) => languagePack.toJson(),
        );
  }

  void _showAddLanguagePackDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        final listOfAllLanguages = NaturalLanguage.list;
        return StatefulBuilder(
            builder: (context, StateSetter setStateInsideDialog) => AlertDialog(
                  icon: Icon(Icons.language,
                      color: Theme.of(context).colorScheme.primary),
                  title: const Text('Create a language pack'),
                  content: Wrap(runSpacing: 16, children: [
                    DropdownMenu<NaturalLanguage>(
                        controller: _languageFilterController,
                        enableFilter: true,
                        enableSearch: true,
                        menuHeight: 300,
                        requestFocusOnTap: true,
                        leadingIcon: const Icon(Icons.search),
                        label: const Text('Language'),
                        dropdownMenuEntries: listOfAllLanguages
                            .map((l) =>
                                DropdownMenuEntry(label: l.name, value: l))
                            .toList(),
                        onSelected: (selectedLang) => setStateInsideDialog(() {
                              _selectedLanguage = selectedLang;
                              if (_selectedLanguage != null &&
                                  _nameFieldController.text.isNotEmpty) {
                                _languagePackCode =
                                    "${_selectedLanguage?.codeShort.toLowerCase() ?? ""}.${_nameFieldController.text.toLowerCase().split(' ').join('-')}";
                                _warningMessage = "";
                              }
                            }),
                        filterCallback:
                            (List<DropdownMenuEntry<NaturalLanguage>> entries,
                                String filter) {
                          final String trimmedFilter =
                              filter.trim().toLowerCase();
                          if (trimmedFilter.isEmpty) {
                            return entries;
                          }
                          return entries
                              .where(
                                (DropdownMenuEntry<NaturalLanguage> entry) =>
                                    entry.label
                                        .toLowerCase()
                                        .contains(trimmedFilter),
                              )
                              .toList();
                        },
                        searchCallback:
                            (List<DropdownMenuEntry<NaturalLanguage>> entries,
                                String query) {
                          if (query.isEmpty) {
                            return null;
                          }
                          final int index = entries.indexWhere(
                              (DropdownMenuEntry<NaturalLanguage> entry) =>
                                  entry.label == query);
                          return index != -1 ? index : null;
                        }),
                    TextField(
                      controller: _nameFieldController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Pack name',
                          hintText: 'Daily Phrases'),
                      onChanged: (val) {
                        setStateInsideDialog(() {
                          if (_selectedLanguage != null) {
                            _languagePackCode =
                                "${_selectedLanguage?.codeShort.toLowerCase() ?? ""}.${val.toLowerCase().split(' ').join('-')}";
                            _warningMessage = "";
                          } else {
                            _codeFieldController.text = '';
                          }
                        });
                      },
                    ),
                    Text(_languagePackCode),
                    Text(_warningMessage,
                        style: Theme.of(context).textTheme.bodyMedium)
                  ]),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Save'),
                      onPressed: () {
                        setStateInsideDialog(() {
                          if (_selectedLanguage == null) {
                            _warningMessage =
                                'Please select a language to create a pack';
                          } else if (_nameFieldController.text.isEmpty) {
                            _warningMessage =
                                'Please enter name to create a pack';
                          }
                        });
                        setState(() {
                          if (_selectedLanguage != null &&
                              _languagePackCode.isNotEmpty) {
                            FirebaseFirestore.instance
                                .collection('language_packs')
                                .doc(_languagePackCode)
                                .set(LanguagePack(
                                    version: 'draft',
                                    name: _nameFieldController.text,
                                    language: _selectedLanguage!,
                                    phrases: []).toJson());
                            _selectedLanguage = null;
                            _nameFieldController.text = "";
                            Navigator.of(context).pop();
                          }
                        });
                      },
                    ),
                  ],
                ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<QuerySnapshot<LanguagePack>>(
            stream: languagePackRef?.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.requireData;

              return CustomScrollView(slivers: [
                SliverAppBar(
                    pinned: true,
                    flexibleSpace: AppBar(
                        centerTitle: false, title: Text('Language Packs'))),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (context, index) => LanguagePackListTile(
                          packReference: data.docs[index].reference,
                          pack: data.docs[index].data()),
                      childCount: data.size),
                ),
                SliverPadding(padding: EdgeInsets.symmetric(vertical: 16)),
                SliverToBoxAdapter(child: SizedBox(height: 100))
              ]);
            }),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => _showAddLanguagePackDialog()));
  }
}
