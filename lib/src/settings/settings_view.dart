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

class SettingsView extends StatelessWidget {
  final transcriptionURLController = TextEditingController();

  final void Function(String)? saveTranscript;

  String defaultTranscriptURL = '';

  SettingsView({
    super.key,
    required this.defaultTranscriptURL,
    required this.saveTranscript,
  });

  @override
  Widget build(BuildContext context) {
    transcriptionURLController.text = defaultTranscriptURL;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.chevron_left),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: transcriptionURLController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'URL of cloud-run service',
              hintText: 'https://project-euphoina.us-west2.run.app',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            child: const Text('Save', style: TextStyle(fontSize: 20)),
            onPressed: () {
              if (saveTranscript != null) {
                saveTranscript!(transcriptionURLController.text);
              }
            },
          ),
        ],
      ),
    );
  }
}
