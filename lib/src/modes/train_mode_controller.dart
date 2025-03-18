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

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'train_mode_view.dart';
import 'upload_status.dart';

class TrainModeController extends StatefulWidget {
  const TrainModeController({super.key});

  @override
  State<TrainModeController> createState() => _TrainModeControllerState();
}

class _TrainModeControllerState extends State<TrainModeController> {
  final storage = FirebaseStorage.instance;
  final record = AudioRecorder();
  static const LAST_RECORDED_PHRASE_INDEX = 'LAST_RECORDED_PHRASE_INDEX_KEY';
  late SharedPreferences _prefs;
  late VideoPlayerController _playerController;
  var _isRecording = false;
  var _isPlaying = false;
  var _canPlay = false;
  var _uploadStatus = UploadStatus.notStarted;
  var _selectedPhraseIndex = 0;
  List<String> _phrases = [];

  @override
  void initState() {
    super.initState();
    _createPhrases();
  }

  @override
  void dispose() {
    record.dispose();
    super.dispose();
  }

  void _createPhrases() async {
    _prefs = await SharedPreferences.getInstance();
    rootBundle.loadString('assets/phrases.txt').then((content) {
      var lastIndex = _prefs.getInt(LAST_RECORDED_PHRASE_INDEX) ?? 0;
      setState(() {
        _phrases = LineSplitter.split(content).toList();
        _selectedPhraseIndex = min(
          _phrases.length - 1,
          lastIndex == 0 ? 0 : lastIndex + 1,
        );
      });
    });
  }

  void _manageRecording() async {
    if (_isRecording) {
      await _stopRecording();
      setState(() {
        _isRecording = false;
      });
    } else {
      await _startRecording();
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<String> _getRecordingPath() {
    return getApplicationDocumentsDirectory().then(
      (value) => '${value.path}/prompt$_selectedPhraseIndex.wav',
    );
  }

  Future<void> _startRecording() async {
    var path = await _getRecordingPath();
    if (await record.hasPermission()) {
      await record.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        ),
        path: path,
      );
    }
  }

  Future<void> _stopRecording() async {
    var _ = await record.stop();
    final currentIndex = _selectedPhraseIndex;
    final phrase = _phrases[currentIndex];
    Future.wait([_checkIfRecordingFileIsAvailable(), _getRecordingPath()]).then(
      (results) {
        final bool fileExists = results[0] as bool;
        final String filePath = results[1] as String;
        if (fileExists) {
          _prefs.setInt(LAST_RECORDED_PHRASE_INDEX, currentIndex);
          _preparePlayerForFile(audioFile: File(filePath));
          _uploadDataToFirebaseStorage(
            index: currentIndex,
            phrase: phrase,
            audioFile: File(filePath),
          );
        }
      },
    );
  }

  Future<bool> _checkIfRecordingFileIsAvailable() async {
    var recordingFile = File(await _getRecordingPath());
    setState(() {
      _canPlay = recordingFile.existsSync();
    });
    return _canPlay;
  }

  Future<void> _uploadDataToFirebaseStorage({
    required int index,
    required String phrase,
    required File audioFile,
  }) async {
    setState(() {
      _uploadStatus = UploadStatus.started;
    });
    final storageRef = FirebaseStorage.instance.ref();
    final phraseRef = storageRef.child('data/$index/phrase.txt');
    final audioRef = storageRef.child('data/$index/recording.wav');
    try {
      await Future.wait([
        phraseRef.putString(phrase),
        audioRef.putFile(audioFile),
      ]);
      setState(() {
        _uploadStatus = UploadStatus.completed;
      });
    } on FirebaseException catch (e) {
      developer.log('${e.message}');
      setState(() {
        _uploadStatus = UploadStatus.interrupted;
      });
    }
  }

  Future<void> _preparePlayerForFile({required File audioFile}) async {
    _playerController = VideoPlayerController.file(audioFile);
    _playerController.initialize().then((_) {});
    _playerController.addListener(() {
      setState(() {
        _isPlaying = _playerController.value.isPlaying;
      });
    });
  }

  void _playRecording() async {
    if (_isPlaying) {
      _playerController.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _playerController.play();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  void _previousPhrase() async {
    if (_isRecording) {
      await _stopRecording();
      setState(() {
        _isRecording = false;
      });
    }
    setState(() {
      _selectedPhraseIndex = _selectedPhraseIndex - 1;
      _uploadStatus = UploadStatus.notStarted;
    });
    Future.wait([_checkIfRecordingFileIsAvailable(), _getRecordingPath()]).then(
      (results) {
        final bool fileExists = results[0] as bool;
        final String filePath = results[1] as String;
        if (fileExists) {
          _preparePlayerForFile(audioFile: File(filePath));
        }
      },
    );
  }

  void _nextPhrase() async {
    if (_isRecording) {
      await _stopRecording();
      setState(() {
        _isRecording = false;
      });
    }
    setState(() {
      _selectedPhraseIndex = _selectedPhraseIndex + 1;
      _uploadStatus = UploadStatus.notStarted;
    });
    Future.wait([_checkIfRecordingFileIsAvailable(), _getRecordingPath()]).then(
      (results) {
        final bool fileExists = results[0] as bool;
        final String filePath = results[1] as String;
        if (fileExists) {
          _preparePlayerForFile(audioFile: File(filePath));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_phrases.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return TrainModeView(
      index: _selectedPhraseIndex,
      phrase: _phrases[_selectedPhraseIndex],
      previousPhrase:
          (_selectedPhraseIndex == 0 || _isRecording || _isPlaying)
              ? null
              : _previousPhrase,
      nextPhrase:
          (_selectedPhraseIndex == _phrases.length - 1 ||
                  _isRecording ||
                  _isPlaying)
              ? null
              : _nextPhrase,
      record: _isPlaying ? null : _manageRecording,
      isRecording: _isRecording,
      play: _canPlay && !_isRecording ? _playRecording : null,
      isPlaying: _isPlaying,
      isRecorded: _canPlay,
      uploadStatus: _uploadStatus,
    );
  }
}
