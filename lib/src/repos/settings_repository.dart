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
import 'package:shared_preferences/shared_preferences.dart';

final class SettingsRepository extends ChangeNotifier {
  static const _transcribeEndpointKey = 'TRANSCRIBE_URL_KEY';
  static const _autoAdvanceKey = 'AUTO_ADVANCE_KEY';
  static const _richCaptionKey = 'RICH_CAPTION_KEY';
  static const _segmentLevelConfidenceKey = 'SEGMENT_LEVEL_CONFIDENCE_KEY';
  static const _defaultEndpoint = 'DEFAULT_TRANSCRIPTION_ENDPOINT';

  String _transcribeEndpoint = '';
  bool _autoAdvance = false;
  bool _displayRichCaptions = false;
  bool _displaySegmentLevelConfidence = false;

  String get transcribeEndpoint => _transcribeEndpoint;
  bool get autoAdvance => _autoAdvance;

  bool get displayRichCaptions => _displayRichCaptions;
  bool get displaySegmentLevelConfidence => _displaySegmentLevelConfidence;

  Future<void> initFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final preferredEndpoint = prefs.getString(_transcribeEndpointKey);
    _transcribeEndpoint =
        (preferredEndpoint == null || preferredEndpoint.isEmpty)
            ? _defaultEndpoint
            : '';
    _autoAdvance = prefs.getBool(_autoAdvanceKey) ?? false;
    _displayRichCaptions = prefs.getBool(_richCaptionKey) ?? false;
    _displaySegmentLevelConfidence = prefs.getBool(_segmentLevelConfidenceKey) ?? false;
    notifyListeners();
  }

  Future<void> updateTranscribeEndpoint(String updatedEndpoint) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_transcribeEndpointKey, updatedEndpoint.trim());
    _transcribeEndpoint = updatedEndpoint.trim();
    notifyListeners();
  }

  Future<void> updateAutoAdvance(bool updatedAutoAdvancePref) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_autoAdvanceKey, updatedAutoAdvancePref);
    _autoAdvance = updatedAutoAdvancePref;
    notifyListeners();
  }

  Future<void> updateRichCaptions(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_richCaptionKey, show);
    _displayRichCaptions = show;
    notifyListeners();
  }

  Future<void> updateSegmentLevelConfidence(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_segmentLevelConfidenceKey, show);
    _displaySegmentLevelConfidence = show;
    notifyListeners();
  }
}
