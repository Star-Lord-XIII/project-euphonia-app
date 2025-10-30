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

import 'dart:collection';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sealed_languages/sealed_languages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../language_pack/firestore_phrase.dart';
import '../language_pack/language_pack.dart';
import 'language_pack_summary.dart';
import 'phrase.dart';

final class PhrasesRepository extends ChangeNotifier {
  static const lastRecordedPhraseIndexKey = 'LAST_RECORDED_PHRASE_INDEX_KEY';
  static const lastSelectedPhraseType = "LAST_SELECTED_PHRASE_TYPE";
  static const lastSelectedLanguagePack = "LAST_SELECTED_LANGUAGE_PACK";
  static const selectedLanguageCode = "SELECTED_LANGUAGE_PACK";
  LanguagePackSummary? selectedLanguageSummary;

  final List<Phrase> _phrases = [];
  final Map<PhraseType, List> _phrasesByType = {};
  int _currentPhraseIndex = 0;
  PhraseType _currentPhraseType = PhraseType.text;
  List<LanguagePackSummary> _cachedLanguagePackSummaryList = [];
  final Map<String, LanguagePack> _cachedLanguagePackCodeToLanguagePack = {};
  var updated = false;

  UnmodifiableListView<Phrase> get phrases => UnmodifiableListView(_phrases);
  int get currentPhraseIndex => _currentPhraseIndex;
  Phrase? get currentPhrase {
    if (selectedLanguageSummary != null) {
      return _phrases[_currentPhraseIndex];
    }
    return _currentPhraseIndex < 0 ||
            (_currentPhraseIndex >=
                (phrasesByType[currentPhraseType]?.length ?? 0))
        ? null
        : _phrases[phrasesByType[currentPhraseType]![_currentPhraseIndex]];
  }

  PhraseType get currentPhraseType => _currentPhraseType;

  Map<PhraseType, List> get phrasesByType => _phrasesByType;

  Future<void> exportFromAssetFile() async {
    if (updated) {
      return;
    }
    updated = true;
    final languagePackList = [
      // LanguagePackSummary(version: 'draft', name: 'Ugandan english long', language: NaturalLanguage.fromCodeShort('en'), languagePackCode: 'en.ugandan-english-long', phrasesCount: 100),
      // LanguagePackSummary(version: 'draft', name: 'Luganda text prompts long', language: NaturalLanguage.fromCodeShort('lg'), languagePackCode: 'lg.luganda-text-prompts-long', phrasesCount: 120),
      // LanguagePackSummary(version: 'draft', name: 'Ugandan images', language: NaturalLanguage.fromCodeShort('en'), languagePackCode: 'en.ugandan-images', phrasesCount: 66),
      // LanguagePackSummary(version: 'draft', name: 'Ugandan english', language: NaturalLanguage.fromCodeShort('en'), languagePackCode: 'en.ugandan-english', phrasesCount: 200),
      // LanguagePackSummary(version: 'draft', name: 'Luganda text prompts', language: NaturalLanguage.fromCodeShort('lg'), languagePackCode: 'lg.luganda-text-prompts', phrasesCount: 210),
      // LanguagePackSummary(version: 'draft', name: 'Ugandan luo text phrases', language: NaturalLanguage.fromCodeShort('lg'), languagePackCode: 'lg.ugandan-luo-text-prompts', phrasesCount: 200),
      // LanguagePackSummary(version: 'draft', name: 'Ewe daily phrases', language: NaturalLanguage.fromCodeShort('ee'), languagePackCode: 'ee.ewe-daily-phrases', phrasesCount: 100),
      // LanguagePackSummary(version: 'draft', name: 'Dagbani daily phrases', language: NaturalLanguage.fromCodeShort('ee'), languagePackCode: 'ee.dagbani-daily-phrases', phrasesCount: 199),
      // LanguagePackSummary(version: 'draft', name: 'English complicated', language: NaturalLanguage.fromCodeShort('en'), languagePackCode: 'en.english-complicated', phrasesCount: 100),
      // LanguagePackSummary(version: 'draft', name: 'Kenyan english', language: NaturalLanguage.fromCodeShort('en'), languagePackCode: 'en.kenyan-english', phrasesCount: 200),
      // LanguagePackSummary(version: 'draft', name: 'Sample picture phrases', language: NaturalLanguage.fromCodeShort('en'), languagePackCode: 'en.sample-picture-phrases', phrasesCount: 10),
      // LanguagePackSummary(version: 'draft', name: 'Swahili common', language: NaturalLanguage.fromCodeShort('sw'), languagePackCode: 'sw.swahili-common', phrasesCount: 198),
      // LanguagePackSummary(version: 'draft', name: 'Swahili images', language: NaturalLanguage.fromCodeShort('sw'), languagePackCode: 'sw.swahili-images', phrasesCount: 50),
      // LanguagePackSummary(version: 'draft', name: 'Twi common', language: NaturalLanguage.fromCodeShort('tw'), languagePackCode: 'tw.twi-common', phrasesCount: 247),
      // LanguagePackSummary(version: 'draft', name: 'Twi images', language: NaturalLanguage.fromCodeShort('tw'), languagePackCode: 'tw.twi-images', phrasesCount: 167),
    ];
    for (final pack in languagePackList) {
      rootBundle
          .loadString('assets/export/${pack.languagePackCode}.txt')
          .then((content) {
        final textPhrases = LineSplitter.split(content).toList();
        List<FirestorePhrase> phraseList = [];
        for (var i = 0; i < textPhrases.length; ++i) {
          final curPhrase = FirestorePhrase(
              id: Uuid().v4(), text: textPhrases[i].trim(), active: true);
          phraseList.add(curPhrase);
        }
        final assembledPack = LanguagePack(
            version: pack.version,
            name: pack.name,
            language: pack.language,
            phrases: phraseList);
        FirebaseFirestore.instance
            .collection('language_packs')
            .doc(pack.languagePackCode)
            .set(assembledPack.toJson());
      });
    }
  }

  Future<void> appendFromFile() async {
    if (updated) {
      return;
    }
    updated = true;
    var additionalPhrases = 'assets/export/tw.twi-images.v2.txt';
    var existingLanguagePack = 'tw.twi-images';
    rootBundle.loadString(additionalPhrases).then((content) {
      FirebaseFirestore.instance
          .collection('language_packs')
          .doc(existingLanguagePack)
          .get()
          .then((value) {
        var data = value.data() as Map<String, dynamic>;
        final textPhrases = LineSplitter.split(content).toList();
        List<dynamic> phraseListJson = data['phrases'];
        List<FirestorePhrase> phraseList = phraseListJson
            .map((x) => FirestorePhrase(
                id: x['id'], text: x['text'], active: x['active']))
            .toList();
        for (var i = 0; i < textPhrases.length; ++i) {
          final curPhrase = FirestorePhrase(
              id: Uuid().v4(), text: textPhrases[i].trim(), active: true);
          phraseList.add(curPhrase);
        }
        value.reference
            .update({'phrases': phraseList.map((p) => p.toJson()).toList()});
      });
    });
  }

  Future<void> initFromCloudStorage() async {
    var prefs = await SharedPreferences.getInstance();
    var lastSelectedLanguagePackValue =
        prefs.getString(lastSelectedLanguagePack) ?? '';
    if (lastSelectedLanguagePackValue.isNotEmpty) {
      var languageSummary = LanguagePackSummary.fromJson(
          jsonDecode(lastSelectedLanguagePackValue));
      await updateSelectedLanguagePack(languageSummary);
    }
  }

  Future<LanguagePack?> _getLanguagePack(
      LanguagePackSummary languagePackSummary) async {
    final languagePackVersionCode =
        '${languagePackSummary.languagePackCode}.${languagePackSummary.version}';
    if (_cachedLanguagePackCodeToLanguagePack
        .containsKey(languagePackVersionCode)) {
      return _cachedLanguagePackCodeToLanguagePack[languagePackVersionCode];
    }
    final storageRef = FirebaseStorage.instance.ref();
    final languagePack = storageRef.child(
        'phrases/${languagePackSummary.languagePackCode}.${languagePackSummary.version}.json');
    final Uint8List? languagePackData = await languagePack.getData();
    if (languagePackData != null) {
      String languagePackListContents = Utf8Decoder().convert(languagePackData);
      LanguagePack pack =
          LanguagePack.fromJson(jsonDecode(languagePackListContents));
      _cachedLanguagePackCodeToLanguagePack[languagePackVersionCode] = pack;
      return pack;
    }
    return null;
  }

  Future<void> updateSelectedLanguagePack(
      LanguagePackSummary languagePackSummary) async {
    var prefs = await SharedPreferences.getInstance();
    _currentPhraseIndex = prefs.getInt(
            _currentRecordedPhraseIndexKey(summary: languagePackSummary)) ??
        0;
    selectedLanguageSummary = languagePackSummary;
    LanguagePack? pack = await _getLanguagePack(languagePackSummary);
    if (pack != null) {
      List<Phrase> phrasesList = [];
      for (var i = 0; i < pack.phrases.length; ++i) {
        final curPhrase = Phrase(
            index: i,
            text: pack.phrases[i].text,
            uid: pack.phrases[i].id,
            languagePackCode: pack.languagePackCode);
        phrasesList.add(curPhrase);
        if (phrasesByType[curPhrase.type] == null) {
          phrasesByType[curPhrase.type] = [];
        }
        phrasesByType[curPhrase.type]!.add(i);
      }
      _reset(updatedPhrases: phrasesList);
    }
  }

  Future<List<LanguagePackSummary>>
      getLanguagePackSummaryListFromCloudStorage() async {
    if (_cachedLanguagePackSummaryList.isNotEmpty) {
      return _cachedLanguagePackSummaryList;
    }
    final storageRef = FirebaseStorage.instance.ref();
    final languagePackList = storageRef.child('phrases/language_packs.json');
    try {
      Uint8List? listData = await languagePackList.getData();
      if (listData != null) {
        String languagePackListContents = Utf8Decoder().convert(listData);
        List<dynamic> languagePackMapList =
            jsonDecode(languagePackListContents);
        List<LanguagePackSummary> languagePackSummaryList = [];
        for (final Map<String, dynamic> languagePack in languagePackMapList) {
          languagePackSummaryList
              .add(LanguagePackSummary.fromJson(languagePack));
        }
        _cachedLanguagePackSummaryList = languagePackSummaryList;
        return languagePackSummaryList;
      }
    } on FirebaseException catch (e) {
      developer.log('ERROR: ${e.message}');
    }
    return [];
  }

  String _currentRecordedPhraseIndexKey(
      {PhraseType? type, LanguagePackSummary? summary}) {
    if (summary != null) {
      final userToken = FirebaseAuth.instance.currentUser?.uid ?? "anonymous";
      return '${lastRecordedPhraseIndexKey}_${userToken}_${summary.languagePackCode}';
    }
    return '${lastRecordedPhraseIndexKey}_${(type ?? _currentPhraseType).name.toUpperCase()}';
  }

  Future<int> getLastRecordedPhraseIndex() async {
    if (selectedLanguageSummary != null) {
      return (await SharedPreferences.getInstance()).getInt(
              _currentRecordedPhraseIndexKey(
                  summary: selectedLanguageSummary)) ??
          0;
    }
    return (await SharedPreferences.getInstance())
            .getInt(_currentRecordedPhraseIndexKey()) ??
        0;
  }

  void _reset({required List<Phrase> updatedPhrases}) {
    _phrases.clear();
    _phrases.addAll(updatedPhrases);
    _currentPhraseIndex = min(max(0, _currentPhraseIndex), phrases.length - 1);
    jumpToPhrase(updatedPhraseIndex: _currentPhraseIndex);
  }

  Future<void> jumpToPhrase(
      {required int updatedPhraseIndex, PhraseType? type}) async {
    _currentPhraseType = type ?? _currentPhraseType;
    _currentPhraseIndex = updatedPhraseIndex;
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(lastSelectedPhraseType, _currentPhraseType.name);
    if (selectedLanguageSummary != null) {
      prefs.setString(lastSelectedLanguagePack,
          jsonEncode(selectedLanguageSummary!.toJson()));
      prefs.setInt(
          _currentRecordedPhraseIndexKey(summary: selectedLanguageSummary),
          _currentPhraseIndex);
    } else {
      prefs.setInt(_currentRecordedPhraseIndexKey(), _currentPhraseIndex);
    }
    notifyListeners();
  }

  Future<void> moveToNextPhrase() async {
    if (currentPhraseIndex + 1 >= phrases.length) {
      return;
    }
    jumpToPhrase(updatedPhraseIndex: currentPhraseIndex + 1);
  }

  Future<void> moveToPreviousPhrase() async {
    jumpToPhrase(updatedPhraseIndex: currentPhraseIndex - 1);
  }

  Future<void> toggleType(PhraseType type) async {
    if (_currentPhraseType == type) {
      return;
    }
    var prefs = await SharedPreferences.getInstance();
    final updatedIndex =
        prefs.getInt(_currentRecordedPhraseIndexKey(type: type)) ?? 0;
    jumpToPhrase(updatedPhraseIndex: updatedIndex, type: type);
  }
}
