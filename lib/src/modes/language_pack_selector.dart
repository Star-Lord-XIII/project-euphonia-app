import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repos/language_pack_summary.dart';
import '../repos/phrases_repository.dart';

class LanguagePackSelector extends StatefulWidget {
  const LanguagePackSelector({super.key});

  @override
  State<StatefulWidget> createState() => _LanguagePackSelectorState();
}

class _LanguagePackSelectorState extends State<LanguagePackSelector> {
  LanguagePackSummary? languagePackSummary;

  @override
  Widget build(BuildContext context) {
    return Consumer<PhrasesRepository>(builder: (_, repo, __) {
      return Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Text('Language Pack Selector',
                  style: Theme.of(context).textTheme.headlineMedium),
              Text(
                  'Select a language pack to start recording phrases.\nYou can switch to another language pack from Settings.',
                  textAlign: TextAlign.center),
              SizedBox(height: 16),
              FutureBuilder(
                  future: repo.getLanguagePackSummaryListFromCloudStorage(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return DropdownMenu(
                          label: Text('Language pack'),
                          dropdownMenuEntries: snapshot.requireData
                              .map((x) => DropdownMenuEntry(
                                  value: x,
                                  label: x.name,
                                  trailingIcon: Wrap(
                                    children: [
                                      Chip(
                                          label: Text(x.language.codeShort
                                              .toLowerCase()),
                                          labelPadding: EdgeInsets.zero,
                                          labelStyle: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          visualDensity: VisualDensity.compact)
                                    ],
                                  )))
                              .toList(),
                          onSelected: (x) {
                            if (x != null) {
                              setState(() {
                                languagePackSummary = x;
                              });
                            }
                          });
                    }
                    return CircularProgressIndicator();
                  }),
              SizedBox(height: 16),
              MaterialButton(
                  onPressed: languagePackSummary == null
                      ? null
                      : () {
                          if (languagePackSummary != null) {
                            repo.updateSelectedLanguagePack(
                                languagePackSummary!);
                          }
                        },
                  child: const Text('Next'))
            ],
          ));
    });
  }
}
