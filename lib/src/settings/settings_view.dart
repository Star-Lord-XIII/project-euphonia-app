// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../generated/l10n/app_localizations.dart';
import '../language_pack/model/language_pack_summary.dart';
import '../repos/phrases_repository.dart';
import '../repos/settings_repository.dart';

class SettingsView extends StatelessWidget {
  final TextEditingController transcriptionURLController;
  final String defaultTranscriptURL;
  final PhrasesRepository repo;
  final SettingsRepository settings;
  final languagePackDropDownUniqueKey = UniqueKey();

  SettingsView(
      {super.key,
      required this.transcriptionURLController,
      required this.defaultTranscriptURL,
      required this.repo,
      required this.settings});

  @override
  Widget build(BuildContext context) {
    final children = [
      const SizedBox(height: 36),
      ListTile(
          title: Text(AppLocalizations.of(context)!.recordModeTitle,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Colors.blue))),
      FutureBuilder(
          future: repo.getLanguagePackSummaryListFromCloudStorage(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListTile(
                  title: Text('Language Pack',
                      style: Theme.of(context).textTheme.headlineSmall),
                  subtitle: Text('Switch to another Language pack'),
                  trailing: DropdownMenu<LanguagePackSummary>(
                      key: languagePackDropDownUniqueKey,
                      initialSelection: repo.selectedLanguageSummary,
                      label: Text(repo.selectedLanguageSummary?.name ??
                          'Language Pack'),
                      dropdownMenuEntries: snapshot.requireData
                          .map((x) => DropdownMenuEntry(
                              value: x,
                              label: x.name,
                              trailingIcon: Wrap(
                                children: [
                                  Chip(
                                      label: Text(
                                          x.language.codeShort.toLowerCase()),
                                      labelPadding: EdgeInsets.zero,
                                      labelStyle:
                                          Theme.of(context).textTheme.bodySmall,
                                      visualDensity: VisualDensity.compact)
                                ],
                              )))
                          .toList(),
                      onSelected: (x) {
                        if (x != null) {
                          repo.updateSelectedLanguagePack(x);
                        }
                      }));
            }
            return Center(child: CircularProgressIndicator());
          }),
      const SizedBox(height: 36),
      ListTile(
        title: Text(AppLocalizations.of(context)!.autoAdvanceSettingTitle,
            style: Theme.of(context).textTheme.headlineSmall),
        subtitle:
            Text(AppLocalizations.of(context)!.autoAdvanceSettingSubtitle),
        trailing: Switch(
            value: settings.autoAdvance,
            onChanged: (newValue) {
              settings.updateAutoAdvance(newValue);
            }),
      ),
      const SizedBox(height: 36),
      ListTile(
          title: Text(AppLocalizations.of(context)!.transcribeModeTitle,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Colors.blue))),
      ListTile(
          title: TextField(
        controller: transcriptionURLController,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: AppLocalizations.of(context)!.cloudRunTextFieldLabel,
          hintText: 'https://project-euphoina.us-west2.run.app',
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        onChanged: (newValue) {
          Provider.of<SettingsRepository>(context, listen: false)
              .updateTranscribeEndpoint(newValue);
        },
      )),
      const SizedBox(height: 36),
      ListTile(
          title: Text('Rich captions',
              style: Theme.of(context).textTheme.headlineSmall),
          subtitle: Text(
              'Display coloured captions to show probability of each word. Green when greater than 0.9, else yellow if greater than 0.7, else red.'),
          trailing: Switch(
              value: settings.displayRichCaptions,
              onChanged: (newValue) {
                settings.updateRichCaptions(newValue);
              })),
      const SizedBox(height: 36),
      ListTile(
          title: Text('Segment level confidence',
              style: Theme.of(context).textTheme.headlineSmall),
          subtitle: Text(
              'Display coloured captions to show confidence at segment level. Green when greater than 0.9, else yellow if greater than 0.7, else red.'),
          trailing: Switch(
              value: settings.displaySegmentLevelConfidence,
              onChanged: (newValue) {
                settings.updateSegmentLevelConfidence(newValue);
              })),
      const SizedBox(height: 64)
    ];

    return Scaffold(
        body: CustomScrollView(slivers: [
      SliverAppBar(
        pinned: true,
        flexibleSpace: AppBar(
            centerTitle: false,
            title: Text(AppLocalizations.of(context)!.settingsMenuDrawerTitle)),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return children[index];
        }, childCount: children.length),
      )
    ]));
  }
}
