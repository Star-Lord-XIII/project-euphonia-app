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

import 'package:flutter/widgets.dart';
import 'package:record/record.dart' as ar;

import 'phrase.dart';

final class AudioRecorder extends ChangeNotifier {
  Phrase? _phrase;
  final _recorder = ar.AudioRecorder();
  var _isRecording = false;

  bool get isRecording => _isRecording;

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
          path: await _phrase!.localRecordingPath,
        );
      }
    });
  }

  void stop() {
    if (isRecording) {
      _recorder.stop();
      _isRecording = false;
      _phrase?.uploadRecording();
      notifyListeners();
    }
  }
}
