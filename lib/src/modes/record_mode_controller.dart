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

import '../repos/audio_player.dart';
import '../repos/audio_recorder.dart';
import '../repos/phrase.dart';
import '../repos/phrases_repository.dart';
import '../repos/settings_repository.dart';
import '../repos/uploader.dart';
import 'language_pack_selector.dart';
import 'record_mode_view.dart';
import 'upload_status.dart';

class RecordModeController extends StatefulWidget {
  const RecordModeController({super.key});

  @override
  State<RecordModeController> createState() => _RecordModeControllerState();
}

class _RecordModeControllerState extends State<RecordModeController> {
  var _uploadStatus = UploadStatus.notStarted;
  final Key _key = GlobalKey();
  PageController? _pageController;

  void _previousPhrase() async {
    var phrasesRepoProvider =
        Provider.of<PhrasesRepository>(context, listen: false);
    await phrasesRepoProvider.moveToPreviousPhrase();
    setState(() {
      _pageController?.animateToPage(phrasesRepoProvider.currentPhraseIndex,
          duration: const Duration(milliseconds: 100), curve: Curves.linear);
      _uploadStatus = UploadStatus.notStarted;
    });
  }

  void _nextPhrase() async {
    var phrasesRepoProvider =
        Provider.of<PhrasesRepository>(context, listen: false);
    await phrasesRepoProvider.moveToNextPhrase();
    setState(() {
      _pageController?.animateToPage(phrasesRepoProvider.currentPhraseIndex,
          duration: const Duration(milliseconds: 100), curve: Curves.linear);
      _uploadStatus = UploadStatus.notStarted;
    });
  }

  Future<void> _stopRecordingAndUpload(
      AudioRecorder recorder, Phrase phrase, AudioPlayer player,
      {autoAdvance = true}) async {
    await recorder.stop();
    Provider.of<Uploader>(context, listen: false)
        .updateStatus(status: UploadStatus.started);
    phrase.uploadRecording().then((_) {
      Provider.of<Uploader>(context, listen: false)
          .updateStatus(status: UploadStatus.completed);
    }, onError: (_) {
      Provider.of<Uploader>(context, listen: false)
          .updateStatus(status: UploadStatus.interrupted);
    });
    if (Provider.of<SettingsRepository>(context, listen: false).autoAdvance &&
        autoAdvance) {
      _nextPhrase();
    }
  }

  void _deleteRecording(Phrase phrase) async {
    await phrase.deleteRecording();
    setState(() {
      _uploadStatus = UploadStatus.notStarted;
    });
  }

  void _toggleType(Set<PhraseType> newSelection) async {
    var phrasesRepoProvider =
        Provider.of<PhrasesRepository>(context, listen: false);
    await phrasesRepoProvider.toggleType(newSelection.first);
    setState(() {
      _pageController?.jumpToPage(phrasesRepoProvider.currentPhraseIndex);
      _uploadStatus = UploadStatus.notStarted;
    });
  }

  void _showRecordingTooLongDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.warning_rounded, color: Colors.yellow),
          title: const Text('Recording too long'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Recording was cut after ${AudioRecorder.maxTicksAllowed / 10} seconds.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<PhrasesRepository, AudioPlayer, AudioRecorder>(
        builder: (_, repo, player, recorder, __) {
      if (repo.selectedLanguageSummary == null) {
        return const Center(child: LanguagePackSelector());
      }
      if (repo.phrases.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (recorder.isRecording &&
          recorder.ticksPassed >= AudioRecorder.maxTicksAllowed) {
        _stopRecordingAndUpload(recorder, repo.currentPhrase!, player,
                autoAdvance: false)
            .then((_) => _showRecordingTooLongDialog());
      }
      if (repo.phrases.isNotEmpty && _pageController == null) {
        _pageController = PageController(
            initialPage: repo.currentPhraseIndex, viewportFraction: 0.8);
      }
      return RecordModeView(
        type: repo.currentPhraseType,
        phrasesByType: repo.phrasesByType,
        index: repo.currentPhraseIndex,
        pageStorageKey: _key,
        phrases: repo.phrases,
        toggleType: _toggleType,
        previousPhrase: repo.currentPhraseIndex == 0 ? null : _previousPhrase,
        nextPhrase: repo.currentPhraseIndex == repo.phrases.length - 1
            ? null
            : _nextPhrase,
        record: player.isPlaying
            ? null
            : () {
                if (!recorder.isRecording) {
                  recorder.start();
                  return;
                }
                _stopRecordingAndUpload(recorder, repo.currentPhrase!, player);
              },
        isRecording: recorder.isRecording,
        play: player.canPlay && !recorder.isRecording
            ? (player.isPlaying ? player.pause : player.play)
            : null,
        deleteRecording:
            player.canPlay ? () => _deleteRecording(repo.currentPhrase!) : null,
        isPlaying: player.isPlaying,
        isRecorded: player.canPlay,
        uploadStatus: _uploadStatus,
        controller: _pageController,
      );
    });
  }
}
