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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'src/language_pack/model/language_pack_catalog_model.dart';
import 'src/language_pack/repository/language_pack_repo.dart';
import 'src/language_pack/service/database_service.dart';
import 'src/language_pack/service/file_storage_service.dart';
import 'src/language_pack/service/firebase_firestore_service.dart';
import 'src/language_pack/service/firebase_storage_service.dart';
import 'src/project_euphonia.dart';
import 'src/repos/audio_player.dart';
import 'src/repos/audio_recorder.dart';
import 'src/repos/phrases_repository.dart';
import 'src/repos/settings_repository.dart';
import 'src/repos/uploader.dart';
import 'src/repos/websocket_transcriber.dart';
import 'src/repository/model/model_repository.dart';
import 'src/repository/model/model_repository_remote.dart';
import 'src/service/model_training_service.dart';
import 'src/service/model_training_service_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  final auth = FirebaseAuth.instanceFor(app: app);
  const usingEmulator = false;
  if (usingEmulator) {
    await auth.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => PhrasesRepository()),
    ChangeNotifierProxyProvider<PhrasesRepository, AudioRecorder>(
        create: (context) => AudioRecorder(),
        update: (context, phraseRepoChangeNotifier, audioRecorder) =>
            audioRecorder!
              ..updateAudioPathForPhrase(
                  phraseRepoChangeNotifier.currentPhrase)),
    ChangeNotifierProxyProvider<PhrasesRepository, AudioPlayer>(
        create: (context) => AudioPlayer(),
        update: (context, phraseRepoChangeNotifier, audioPlayer) =>
            audioPlayer!..loadPhrase(phraseRepoChangeNotifier.currentPhrase)),
    ChangeNotifierProvider(create: (context) => Uploader()),
    ChangeNotifierProvider(create: (context) => SettingsRepository()),
    ChangeNotifierProvider(create: (context) => WebsocketTranscriber()),
    Provider(
        create: (context) => FirebaseStorageService(
                firebaseStorageRef: FirebaseStorage.instance.ref())
            as FileStorageService),
    Provider(
        create: (context) => FirebaseFirestoreService(
            firestoreInstance: FirebaseFirestore.instance) as DatabaseService),
    Provider(
        create: (context) => LanguagePackRepository(
            fileStorageService: context.read(),
            databaseService: context.read())),
    Provider(
        create: (context) =>
            ModelTrainingServiceImpl() as ModelTrainingService),
    Provider(
        create: (context) =>
            ModelRepositoryRemote(modelTrainingService: context.read())
                as ModelRepository),
    ChangeNotifierProvider(create: (context) => LanguagePackCatalogModel())
  ], child: const ProjectEuphonia()));
}
