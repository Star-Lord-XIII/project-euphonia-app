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

import '../generated/l10n/app_localizations.dart';
import '../repos/audio_recorder.dart';
import '../repos/phrase.dart';
import '../repos/phrases_repository.dart';
import 'phrase_view.dart';
import 'upload_status.dart';

class RecordModeView extends StatelessWidget {
  final PhraseType type;
  final Map<PhraseType, List> phrasesByType;
  final int index;
  final Key pageStorageKey;
  final List<Phrase> phrases;
  final void Function(Set<PhraseType>)? toggleType;
  final void Function()? record;
  final void Function()? play;
  final void Function()? nextPhrase;
  final void Function()? previousPhrase;
  final void Function()? deleteRecording;
  final void Function()? transcribeRecording;
  final void Function()? saveTranscription;
  final bool isRecording;
  final bool isPlaying;
  final bool isRecorded;
  final bool isTranscribing;
  final UploadStatus uploadStatus;
  final UploadStatus transcriptionStatus;
  final PageController? controller;
  final TextEditingController transcriptFieldController;

  const RecordModeView(
      {super.key,
      required this.pageStorageKey,
      required this.type,
      required this.phrasesByType,
      required this.index,
      required this.phrases,
      required this.toggleType,
      required this.nextPhrase,
      required this.previousPhrase,
      required this.deleteRecording,
      required this.transcribeRecording,
      required this.saveTranscription,
      required this.record,
      required this.play,
      required this.isRecording,
      required this.isPlaying,
      required this.isRecorded,
      required this.isTranscribing,
      required this.uploadStatus,
      required this.transcriptionStatus,
      this.controller,
      required this.transcriptFieldController});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var ticksPassed =
        Provider.of<AudioRecorder>(listen: false, context).ticksPassed;
    var progress = ticksPassed / AudioRecorder.maxTicksAllowed;
    // Only start displaying red in timer once 5 seconds are left.
    var progressColor = AudioRecorder.maxTicksAllowed - ticksPassed > 50
        ? Theme.of(context).colorScheme.primary
        : Color.lerp(
            Theme.of(context).colorScheme.primary, Colors.red, progress);
    var sideLength = width;
    if (height < width) {
      sideLength = height - 180;
    }
    return OrientationBuilder(builder: (context, orientation) {
      final List<Widget> firstHalf = [
        SizedBox(
            width: orientation == Orientation.landscape
                ? (width * 2 / 3) - 100
                : sideLength,
            height: sideLength,
            child: PageView.builder(
                key: pageStorageKey,
                controller: controller,
                itemBuilder: (context, index) {
                  return PhraseView(index: index, phrase: phrases[index]);
                },
                itemCount: phrases.length,
                onPageChanged: (index) =>
                    Provider.of<PhrasesRepository>(context, listen: false)
                        .jumpToPhrase(updatedPhraseIndex: index))),
      ];

      final List<Widget> secondQuarter = (isTranscribing
          ? [
              Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: TextField(
                    controller: transcriptFieldController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Transcription',
                        hintText: 'What did the user say?'),
                    minLines: 3,
                    maxLines: 3,
                  )),
              SizedBox(height: 8),
              Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MaterialButton(
                            color: transcriptionStatus == UploadStatus.interrupted ? Colors.red : (
                                transcriptionStatus == UploadStatus.completed ? Colors.green : Colors.blue),
                            onPressed: saveTranscription,
                            child: Row(children: [
                            Visibility(visible: transcriptionStatus == UploadStatus.completed, child: Icon(Icons.check)),
                            Visibility(visible: transcriptionStatus == UploadStatus.started, child:
                              SizedBox(height: 20, width: 20, child:
                                CircularProgressIndicator())),
                            const Text('Save')]))
                      ]))
            ].cast()
          : [
              MaterialButton(
                onPressed: record,
                color: isRecording
                    ? Colors.teal
                    : (isRecorded ? Colors.lightBlueAccent : Colors.blue),
                textColor: Colors.white,
                disabledColor: Colors.grey,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(80)),
                ),
                padding: const EdgeInsets.fromLTRB(80, 24, 80, 24),
                child:  Text(
                  isRecording
                      ? AppLocalizations.of(context)!.stopRecordingButtonTitle
                      : (isRecorded
                          ? AppLocalizations.of(context)!.reRecordButtonTitle
                          : AppLocalizations.of(context)!.recordButtonTitle),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 24)
            ].cast<Widget>());

      final List<Widget> secondHalf = [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Semantics(
                  label: AppLocalizations.of(context)!.deleteRecordingButton,
                  hint: AppLocalizations.of(context)!.deleteRecordingButtonHint,
                  child: IconButton.outlined(
                      onPressed: deleteRecording,
                      iconSize: 24,
                      icon: const Icon(Icons.delete)),
                ),
                const SizedBox(width: 24),
                Semantics(
                    label: AppLocalizations.of(context)!.previousPhraseButton,
                    hint:
                        AppLocalizations.of(context)!.previousPhraseButtonHint,
                    child: IconButton.outlined(
                      onPressed: previousPhrase,
                      iconSize: 48,
                      icon: const Icon(Icons.skip_previous),
                    )),
                const SizedBox(width: 24),
                isRecording
                    ? Stack(children: [
                        SizedBox(
                            height: 36,
                            width: 36,
                            child: Center(
                                child: Text(
                                    Provider.of<AudioRecorder>(context)
                                        .recordingTime,
                                    style: TextStyle(
                                        fontSize: 16, color: progressColor)))),
                        Transform.scale(
                            scale: 1.6,
                            child: CircularProgressIndicator(
                                value: progress, color: progressColor)),
                      ])
                    : Semantics(
                        label: AppLocalizations.of(context)!.playPhraseButton,
                        hint:
                            AppLocalizations.of(context)!.playPhraseButtonHint,
                        child: IconButton.outlined(
                          onPressed: play,
                          iconSize: 48,
                          icon:
                              Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                        )),
                SizedBox(width: 24),
                Semantics(
                    label: AppLocalizations.of(context)!.nextPhraseButton,
                    hint: AppLocalizations.of(context)!.nextPhraseButtonHint,
                    child: IconButton.outlined(
                      onPressed: nextPhrase,
                      iconSize: 48,
                      icon: const Icon(Icons.skip_next),
                    )),
                SizedBox(width: 24),
                Semantics(
                  label:
                      AppLocalizations.of(context)!.transcribeRecordingButton,
                  hint: AppLocalizations.of(context)!
                      .transcribeRecordingButtonHint,
                  child: IconButton.outlined(
                      onPressed: transcribeRecording,
                      iconSize: 24,
                      icon: const Icon(Icons.transcribe)),
                ),
              ],
            ),
            const SizedBox(height: 32)
          ].cast<Widget>() +
          secondQuarter;
      return orientation == Orientation.portrait
          ? SingleChildScrollView(
              child: Column(children: firstHalf + secondHalf))
          : SingleChildScrollView(
              child: Row(children: [
              Column(children: firstHalf),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 8),
                      child: Column(children: secondHalf)))
            ]));
    });
  }
}
