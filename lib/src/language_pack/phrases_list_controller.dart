import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../common/result.dart';
import 'model/phrase.dart';
import 'model/language_pack.dart';
import 'repository/language_pack_repo.dart';
import 'view/phrases_list_tile.dart';

class PhrasesListController extends StatefulWidget {
  final String documentPath;
  const PhrasesListController({super.key, required this.documentPath});

  @override
  State<PhrasesListController> createState() => _PhrasesListControllerState();
}

class _PhrasesListControllerState extends State<PhrasesListController> {
  final TextEditingController _phraseFieldController = TextEditingController();
  late LanguagePackRepository languagePackRepository;
  LanguagePack? languagePack;
  String _warningMessage = '';
  var isUpdating = false;

  @override
  void initState() {
    languagePackRepository = context.read();
    languagePackRepository
        .getLanguagePack(languagePackId: widget.documentPath)
        .then((lp) {
      setState(() {
        switch (lp) {
          case Ok<LanguagePack>():
            languagePack = lp.value;
            break;
          case Error<void>():
            _warningMessage =
                'Something went wrong while reading languagePack with id: ${widget.documentPath}';
            break;
        }
      });
    });
    super.initState();
  }

  void _showAddNewPhraseDialog({required List<Phrase> currentPhrases}) {
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
                          var phrasesList = currentPhrases;
                          final newPhrase = Phrase(
                              id: Uuid().v4(),
                              text: _phraseFieldController.text,
                              active: true);
                          phrasesList.add(newPhrase);
                          setState(() {
                            languagePack!.phrases = phrasesList;
                          });
                          languagePackRepository.updateLanguagePack(
                              languagePackId: languagePack!.languagePackCode,
                              phrases: phrasesList);
                          _phraseFieldController.text = '';
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ));
      },
    );
  }

  Future<void> publishLanguagePack(LanguagePack languagePack) async {
    setState(() {
      isUpdating = true;
    });
    languagePack.updateVersion();
    await languagePackRepository.publishLanguagePack(languagePack);
    setState(() {
      isUpdating = false;
      languagePack = languagePack;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (languagePack == null) {
      return Center(child: CircularProgressIndicator());
    }
    if (_warningMessage.isNotEmpty) {
      return Center(
        child: Text(_warningMessage),
      );
    }
    return Scaffold(
        body: CustomScrollView(slivers: [
          SliverAppBar(
              pinned: true,
              flexibleSpace: AppBar(
                centerTitle: false,
                title: Text(
                    "${languagePack?.name ?? "NA"} (${languagePack?.language.name ?? "NA"})"),
                actions: isUpdating
                    ? [
                        CircularProgressIndicator(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                        )
                      ]
                    : [
                        Text(languagePack?.version ?? "NA"),
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
                                publishLanguagePack(languagePack!);
                              },
                            )
                          ],
                        ),
                      ],
              )),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final phrase = languagePack!.phrases[index];
              return PhrasesListTile(
                  phrase: phrase,
                  onChanged: (updatedSelection) async {
                    var phrasesList = languagePack!.phrases;
                    phrasesList[index].active = !phrasesList[index].active;
                    await languagePackRepository.updateLanguagePack(
                        languagePackId: widget.documentPath,
                        phrases: phrasesList);
                    setState(() {
                      languagePack!.phrases = phrasesList;
                    });
                  });
            }, childCount: languagePack?.phrases.length ?? 0),
          ),
          SliverPadding(padding: EdgeInsets.symmetric(vertical: 16)),
          SliverToBoxAdapter(child: SizedBox(height: 100))
        ]),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => _showAddNewPhraseDialog(
                currentPhrases: languagePack?.phrases ?? [])));
  }
}
