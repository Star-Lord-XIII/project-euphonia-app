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

  final List<Phrase> _phrases = [];
  int _currentPhraseIndex = 0;

  UnmodifiableListView<Phrase> get phrases => UnmodifiableListView(_phrases);
  int get currentPhraseIndex => _currentPhraseIndex;
  Phrase? get currentPhrase =>
      _currentPhraseIndex < 0 || _currentPhraseIndex >= _phrases.length
          ? null
          : _phrases[_currentPhraseIndex];

  Future<void> initFromAssetFile() async {
    var prefs = await SharedPreferences.getInstance();
    rootBundle.loadString('assets/phrases.txt').then((content) {
      _currentPhraseIndex = prefs.getInt(lastRecordedPhraseIndexKey) ?? 0;
      var textPhrases = LineSplitter.split(content).toList();
      List<Phrase> phrasesList = [];
      for (var i = 0; i < textPhrases.length; ++i) {
        phrasesList.add(Phrase(index: i, text: textPhrases[i]));
      }
      reset(updatedPhrases: phrasesList);
    });
  }

  Future<int> getLastRecordedPhraseIndex() async {
    return (await SharedPreferences.getInstance())
            .getInt(lastRecordedPhraseIndexKey) ??
        0;
  }

  void reset({required List<Phrase> updatedPhrases}) {
    _phrases.clear();
    _phrases.addAll(updatedPhrases);
    jumpToPhrase(updatedPhraseIndex: _currentPhraseIndex);
    notifyListeners();
  }

  Future<void> jumpToPhrase({required int updatedPhraseIndex}) async {
    if (_currentPhraseIndex == updatedPhraseIndex) {
      return;
    }
    _currentPhraseIndex = updatedPhraseIndex;
    var prefs = await SharedPreferences.getInstance();
    prefs.setInt(lastRecordedPhraseIndexKey, _currentPhraseIndex);
    notifyListeners();
  }

  Future<void> moveToNextPhrase() async {
    jumpToPhrase(updatedPhraseIndex: currentPhraseIndex + 1);
  }

  Future<void> moveToPreviousPhrase() async {
    jumpToPhrase(updatedPhraseIndex: currentPhraseIndex - 1);
  }
}
