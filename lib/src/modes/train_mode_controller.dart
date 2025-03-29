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

import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repos/audio_player.dart';
import '../repos/audio_recorder.dart';
import '../repos/phrases_repository.dart';
import 'train_mode_view.dart';
import 'upload_status.dart';

class TrainModeController extends StatefulWidget {
  const TrainModeController({super.key});

  @override
  State<TrainModeController> createState() => _TrainModeControllerState();
}

class _TrainModeControllerState extends State<TrainModeController> {
  var _uploadStatus = UploadStatus.notStarted;
  final _pageController = PageController(initialPage: 0, viewportFraction: 0.8);

  @override
  void initState() {
    super.initState();
    Provider.of<PhrasesRepository>(context, listen: false)
        .getLastRecordedPhraseIndex()
        .then((lastRecordedPhraseIndex) => setState(() {
              if (_pageController.hasClients) {
                _pageController.jumpToPage(lastRecordedPhraseIndex);
              }
            }));
  }

  void _previousPhrase() async {
    var phrasesRepoProvider =
        Provider.of<PhrasesRepository>(context, listen: false);
    phrasesRepoProvider.moveToPreviousPhrase();
    setState(() {
      _pageController.animateToPage(phrasesRepoProvider.currentPhraseIndex,
          duration: const Duration(milliseconds: 100), curve: Curves.linear);
      _uploadStatus = UploadStatus.notStarted;
    });
  }

  void _nextPhrase() async {
    var phrasesRepoProvider =
        Provider.of<PhrasesRepository>(context, listen: false);
    phrasesRepoProvider.moveToNextPhrase();
    setState(() {
      _pageController.animateToPage(phrasesRepoProvider.currentPhraseIndex,
          duration: const Duration(milliseconds: 100), curve: Curves.linear);
      _uploadStatus = UploadStatus.notStarted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<PhrasesRepository, AudioPlayer, AudioRecorder>(
        builder: (_, repo, player, recorder, _1) {
      if (repo.phrases.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return TrainModeView(
        index: repo.currentPhraseIndex,
        phrases: repo.phrases,
        previousPhrase: repo.currentPhraseIndex == 0 ? null : _previousPhrase,
        nextPhrase: repo.currentPhraseIndex == repo.phrases.length - 1
            ? null
            : _nextPhrase,
        record: player.isPlaying
            ? null
            : (recorder.isRecording ? recorder.stop : recorder.start),
        isRecording: recorder.isRecording,
        play: player.canPlay && !recorder.isRecording
            ? (player.isPlaying ? player.pause : player.play)
            : null,
        isPlaying: player.isPlaying,
        isRecorded: player.canPlay,
        uploadStatus: _uploadStatus,
        controller: _pageController,
      );
    });
  }
}
