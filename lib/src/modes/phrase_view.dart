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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../repos/phrase.dart';

final class PhraseView extends StatelessWidget {
  final int _index;
  final Phrase _phrase;

  const PhraseView({super.key, required int index, required Phrase phrase})
      : _index = index,
        _phrase = phrase;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _phrase.isRecordingAvailableLocally,
        builder: (context, snapshot) {
          var isRecordingAvailable = (snapshot.data == true);
          return OrientationBuilder(builder: (context, orientation) {
            return Card(
              margin: EdgeInsets.symmetric(
                  vertical: orientation == Orientation.portrait ? 48 : 0,
                  horizontal: 6),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(48)),
              ),
              color: isRecordingAvailable
                  ? ColorScheme.of(context).onTertiary
                  : ColorScheme.of(context).onSecondary,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            '$_index',
                            style: TextStyle(
                                color: ColorScheme.of(context).outline),
                          ),
                        ),
                        Container(
                          decoration: ShapeDecoration(
                            shape: const CircleBorder(),
                            color: !isRecordingAvailable
                                ? Colors.transparent
                                : Colors.blue,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.check_rounded,
                            color: !isRecordingAvailable
                                ? Colors.transparent
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                    _phrase.type == PhraseType.image
                        ? Expanded(
                            child: Center(
                                child: FutureBuilder(
                                    future: _phrase.imageUrl,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return CircularProgressIndicator();
                                      }
                                      return CachedNetworkImage(
                                          imageUrl: snapshot.requireData,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error));
                                    })))
                        : Expanded(
                            child: Center(
                              child: Text(
                                _phrase.text,
                                style: TextTheme.of(context)
                                    .headlineMedium
                                    ?.copyWith(
                                        color: isRecordingAvailable
                                            ? ColorScheme.of(context).tertiary
                                            : ColorScheme.of(context)
                                                .secondary),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            );
          });
        });
  }
}
