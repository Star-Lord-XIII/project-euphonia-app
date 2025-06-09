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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'phrase.dart';

final class PhrasesRepository extends ChangeNotifier {
  static const lastRecordedPhraseIndexKey = 'LAST_RECORDED_PHRASE_INDEX_KEY';
  static const lastSelectedPhraseType = "LAST_SELECTED_PHRASE_TYPE";

  final List<Phrase> _phrases = [];
  final Map<PhraseType, List> _phrasesByType = {};
  int _currentPhraseIndex = 0;
  PhraseType _currentPhraseType = PhraseType.text;

  UnmodifiableListView<Phrase> get phrases => UnmodifiableListView(_phrases);
  int get currentPhraseIndex => _currentPhraseIndex;
  Phrase? get currentPhrase => _currentPhraseIndex < 0 ||
          (_currentPhraseIndex >=
              (phrasesByType[currentPhraseType]?.length ?? 0))
      ? null
      : _phrases[phrasesByType[currentPhraseType]![_currentPhraseIndex]];

  PhraseType get currentPhraseType => _currentPhraseType;

  Map<PhraseType, List> get phrasesByType => _phrasesByType;

  Future<void> initFromAssetFile() async {
    var prefs = await SharedPreferences.getInstance();
    rootBundle.loadString('assets/swahili_phrases.txt').then((content) {
      _currentPhraseType = PhraseType.values
          .byName(prefs.getString(lastSelectedPhraseType) ?? "text");
      _currentPhraseIndex = prefs.getInt(_currentRecordedPhraseIndexKey()) ?? 0;
      var textPhrases = LineSplitter.split(content).toList();
      List<Phrase> phrasesList = [];
      for (var i = 0; i < textPhrases.length; ++i) {
        final curPhrase = Phrase(index: i, text: textPhrases[i]);
        phrasesList.add(curPhrase);
        if (_phrasesByType[curPhrase.type] == null) {
          _phrasesByType[curPhrase.type] = [];
        }
        _phrasesByType[curPhrase.type]!.add(i);
      }
      reset(updatedPhrases: phrasesList);
    });
  }

  String _currentRecordedPhraseIndexKey({PhraseType? type}) {
    return '${lastRecordedPhraseIndexKey}_${(type ?? _currentPhraseType).name.toUpperCase()}';
  }

  Future<int> getLastRecordedPhraseIndex() async {
    return (await SharedPreferences.getInstance())
            .getInt(_currentRecordedPhraseIndexKey()) ??
        0;
  }

  void reset({required List<Phrase> updatedPhrases}) {
    _phrases.clear();
    _phrases.addAll(updatedPhrases);
    jumpToPhrase(updatedPhraseIndex: _currentPhraseIndex);
    notifyListeners();
  }

  Future<void> jumpToPhrase(
      {required int updatedPhraseIndex, PhraseType? type}) async {
    if (_currentPhraseIndex == updatedPhraseIndex && type == null) {
      return;
    }
    _currentPhraseType = type ?? _currentPhraseType;
    _currentPhraseIndex = updatedPhraseIndex;
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(lastSelectedPhraseType, _currentPhraseType.name);
    prefs.setInt(_currentRecordedPhraseIndexKey(), _currentPhraseIndex);
    notifyListeners();
  }

  Future<void> moveToNextPhrase() async {
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
