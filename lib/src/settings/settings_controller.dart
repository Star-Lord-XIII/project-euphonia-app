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

import '../generated/l10n/app_localizations.dart';
import 'settings_view.dart';

final class SettingsController extends StatefulWidget {
  const SettingsController({super.key});

  @override
  State<SettingsController> createState() => _SettingsControllerState();
}

class _SettingsControllerState extends State<SettingsController> {
  late SharedPreferences _preferences;
  String transcriptURL = '';
  static const TRANSCRIBE_URL_KEY = 'TRANSCRIBE_URL_KEY';

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  void _initPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    final url = _preferences.getString(TRANSCRIBE_URL_KEY) ?? '';
    setState(() {
      transcriptURL = url;
    });
  }

  void saveTranscribeURL(String url) async {
    await _preferences.setString(TRANSCRIBE_URL_KEY, url);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.valueSavedMessage)));
  }

  @override
  Widget build(BuildContext context) {
    return SettingsView(
      defaultTranscriptURL: transcriptURL,
      saveTranscript: saveTranscribeURL,
    );
  }
}
