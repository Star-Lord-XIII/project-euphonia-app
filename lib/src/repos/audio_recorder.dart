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

import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:record/record.dart' as ar;

import 'phrase.dart';

final class AudioRecorder extends ChangeNotifier {
  static const maxTicksAllowed = 300; // 30 sec

  Phrase? _phrase;
  final _recorder = ar.AudioRecorder();
  var _isRecording = false;
  Timer? _timer;
  String _recordingTime = "0";
  int _ticksPassed = 0;

  bool get isRecording => _isRecording;

  String get recordingTime => _recordingTime;

  int get ticksPassed => _ticksPassed;

  void updateAudioPathForPhrase(Phrase? phrase) {
    if (phrase == null) {
      return;
    }
    stop();
    _phrase = phrase;
  }

  void start() {
    if (_phrase == null) {
      throw StateError('Audio path is not set!');
    }
    _isRecording = true;
    notifyListeners();
    _recorder.hasPermission().then((hasPermission) async {
      if (hasPermission) {
        _recorder.start(
          const ar.RecordConfig(
            encoder: ar.AudioEncoder.wav,
            sampleRate: 16000,
            numChannels: 1,
            autoGain: true,
            echoCancel: true,
            noiseSuppress: true,
          ),
          path: await _phrase!.localTempPath,
        );
        _timer = Timer.periodic(const Duration(milliseconds: 100), (Timer t) {
          _recordingTime = "${(t.tick / 10)}";
          _ticksPassed = t.tick;
          notifyListeners();
        });
      }
    });
  }

  Future<void> stop() async {
    if (isRecording) {
      await _recorder.stop();
      await File(await _phrase!.localTempPath)
          .rename(await _phrase!.localRecordingPath);
      _isRecording = false;
      _timer?.cancel();
      _recordingTime = "0";
      _ticksPassed = 0;
      _timer = null;
      notifyListeners();
    }
  }
}
