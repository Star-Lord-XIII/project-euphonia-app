import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_euphonia/src/language_pack/repository/language_pack_repo.dart';
import 'package:uuid/uuid.dart';

import 'model/firestore_phrase.dart';
import 'model/language_pack.dart';
import 'view/phrases_list_tile.dart';

class PhrasesListController extends StatefulWidget {
  final DocumentReference<LanguagePack> reference;
  const PhrasesListController({super.key, required this.reference});

  @override
  State<PhrasesListController> createState() => _PhrasesListControllerState();
}

class _PhrasesListControllerState extends State<PhrasesListController> {
  final TextEditingController _phraseFieldController = TextEditingController();
  String _warningMessage = '';
  var isUpdating = false;

  void _showAddNewPhraseDialog(
      {required List<FirestorePhrase> currentPhrases}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, StateSetter setStateInsideDialog) => AlertDialog(
                  icon: Icon(Icons.language,
                      color: Theme.of(context).colorScheme.primary),
                  title: const Text('Add new phrase'),
                  content: Wrap(runSpacing: 16, children: [
                    TextField(
                      controller: _phraseFieldController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Phrase',
                          hintText: 'Good morning'),
                      minLines: 1,
                      maxLines: 3,
                      maxLength: 70,
                    ),
                    Text(_warningMessage,
                        style: Theme.of(context).textTheme.bodyMedium)
                  ]),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        setState(() {
                          _phraseFieldController.text = "";
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Save'),
                      onPressed: () {
                        if (_phraseFieldController.text.isEmpty) {
                          setStateInsideDialog(() {
                            _warningMessage =
                                'Please enter text to create a phrase';
                          });
                        }
                        if (_phraseFieldController.text.isNotEmpty) {
                          setState(() {
                            var phrasesList = currentPhrases;
                            final newPhrase = FirestorePhrase(
                                id: Uuid().v4(),
                                text: _phraseFieldController.text,
                                active: true);
                            phrasesList.add(newPhrase);
                            widget.reference.update(<String, dynamic>{
                              'phrases':
                                  phrasesList.map((p) => p.toJson()).toList()
                            });
                            _phraseFieldController.text = '';
                            Navigator.of(context).pop();
                          });
                        }
                      },
                    ),
                  ],
                ));
      },
    );
  }

  Future<void> publishLanguagePack(LanguagePack languagePack) async {
    // TODO: This needs to be connected to repo
    languagePack.updateVersion();
    setState(() {
      isUpdating = true;
    });
    // TODO: This needs to be connected to repo
    // languagePack.publishToCloudStorage();
    await widget.reference.update(languagePack.toJson());
    setState(() {
      isUpdating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<LanguagePack>>(
        stream: widget.reference.snapshots(),
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

          return Scaffold(
              body: CustomScrollView(slivers: [
                SliverAppBar(
                    pinned: true,
                    flexibleSpace: AppBar(
                      centerTitle: false,
                      title: Text(
                          "${data.data()?.name ?? "NA"} (${data.data()?.language.name})"),
                      actions: isUpdating
                          ? [
                              CircularProgressIndicator(
                                padding: EdgeInsets.symmetric(horizontal: 32),
                              )
                            ]
                          : [
                              Text(data.data()!.version),
                              PopupMenuButton(
                                icon: Icon(Icons.more_vert),
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry>[
                                  PopupMenuItem(
                                    child: const ListTile(
                                      leading: Icon(Icons.publish),
                                      title: Text('Publish'),
                                    ),
                                    onTap: () async {
                                      final languagePack = data.data()!;
                                      publishLanguagePack(languagePack);
                                    },
                                  )
                                ],
                              ),
                            ],
                    )),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final phrase = data.data()!.phrases[index];
                    return PhrasesListTile(
                        phrase: phrase,
                        onChanged: (updatedSelection) {
                          var phrasesList = data.data()!.phrases;
                          phrasesList[index].active =
                              !phrasesList[index].active;
                          widget.reference.update(<String, dynamic>{
                            'phrases':
                                phrasesList.map((p) => p.toJson()).toList()
                          });
                        });
                  }, childCount: data.data()?.phrases.length ?? 0),
                ),
                SliverPadding(padding: EdgeInsets.symmetric(vertical: 16)),
                SliverToBoxAdapter(child: SizedBox(height: 100))
              ]),
              floatingActionButton: FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () => _showAddNewPhraseDialog(
                      currentPhrases: data.data()?.phrases ?? [])));
        });
  }
}
