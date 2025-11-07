import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_euphonia/src/common/result.dart';
import 'package:project_euphonia/src/language_pack/model/phrase.dart';
import 'package:project_euphonia/src/language_pack/model/language_pack.dart';
import 'package:project_euphonia/src/language_pack/model/language_pack_summary.dart';
import 'package:project_euphonia/src/language_pack/repository/language_pack_repo.dart';
import 'package:project_euphonia/src/language_pack/service/firebase_firestore_service.dart';
import 'package:project_euphonia/src/language_pack/service/firebase_storage_service.dart';
import 'package:sealed_languages/sealed_languages.dart';

void main() async {
  final mockFirebaseStorage = MockFirebaseStorage();
  final mockFirestore = FakeFirebaseFirestore();
  final languagePackJsonList = """
    [
      {
          "version": "v1",
          "name": "English complicated",
          "language_pack_code": "en.english-complicated",
          "language_code": "en",
          "phrases_count": 100
      },
      {
          "version": "v1",
          "name": "Kenyan english",
          "language_pack_code": "en.kenyan-english",
          "language_code": "en",
          "phrases_count": 200
      }
    ]
    """;
  mockFirebaseStorage
      .ref('phrases/language_packs.json')
      .putString(languagePackJsonList);

  test("test reading Language pack summary list from Firebase storage",
      () async {
    final repo = LanguagePackRepository(
        fileStorageService:
        FirebaseStorageService(firebaseStorageRef: mockFirebaseStorage.ref()),
        databaseService: FirebaseFirestoreService(firestoreInstance: mockFirestore));

    Result<List> fetchedListResult = await repo.getLanguagePackSummaryList();
    List<dynamic> fetchedList = [];
    switch (fetchedListResult) {
      case Ok<List>():
        fetchedList = fetchedListResult.value;
        break;
      case Error<List>():
        break;
    }

    final List<LanguagePackSummary> mappedList = fetchedList
        .map((x) => LanguagePackSummary(
            version: x.version,
            name: x.name,
            language: x.language,
            languagePackCode: x.languagePackCode,
            phrasesCount: x.phrasesCount))
        .toList();
    expect(mappedList.length, 2);
    expect(mappedList.first.version, "v1");
    expect(mappedList.first.languagePackCode, "en.english-complicated");
    expect(mappedList.first.language.codeShort, "EN");
    expect(mappedList.first.phrasesCount, 100);
    expect(mappedList.last.version, "v1");
    expect(mappedList.last.languagePackCode, "en.kenyan-english");
    expect(mappedList.last.language.codeShort, "EN");
    expect(mappedList.last.phrasesCount, 200);
  });

  test("json document from firestore should be parsed correctly", () {
    final repo = LanguagePackRepository(
        fileStorageService:
        FirebaseStorageService(firebaseStorageRef: mockFirebaseStorage.ref()),
        databaseService: FirebaseFirestoreService(firestoreInstance: mockFirestore));

    final converted =
        repo.convertStringToLanguagePackListSummaries(languagePackJsonList);

    expect(converted.length, 2);
    expect(converted.first.version, "v1");
    expect(converted.first.languagePackCode, "en.english-complicated");
    expect(converted.first.language.codeShort, "EN");
    expect(converted.first.phrasesCount, 100);
    expect(converted.last.version, "v1");
    expect(converted.last.languagePackCode, "en.kenyan-english");
    expect(converted.last.language.codeShort, "EN");
    expect(converted.last.phrasesCount, 200);
  });

  test("fetch language pack from firestore", () async {
    final repo = LanguagePackRepository(
    fileStorageService:
    FirebaseStorageService(firebaseStorageRef: mockFirebaseStorage.ref()),
    databaseService: FirebaseFirestoreService(firestoreInstance: mockFirestore));

    final newLanguagePack = LanguagePack(
        version: "draft",
        name: "English Simple",
        language: NaturalLanguage.fromCodeShort("en"),
        phrases: [
          Phrase(id: '1', text: "Hello, World!", active: true),
          Phrase(id: '2', text: "A quick brown fox", active: true),
          Phrase(id: '3', text: "Jumps over lazy fox", active: false),
        ]);

    await repo.addLanguagePack(languagePack: newLanguagePack);

    final getLanguagePackResult = await repo.getLanguagePack(languagePackId: 'en.english-simple');

    LanguagePack? languagePack;
    switch(getLanguagePackResult) {
      case Ok<LanguagePack>():
        languagePack = getLanguagePackResult.value;
        break;
      case Error<void>():
        break;
    }
    expect(jsonEncode(languagePack?.toJson()), jsonEncode(newLanguagePack.toJson()));
  });

  test("Update language packs and summary list", () async {
    final repo = LanguagePackRepository(
        fileStorageService:
            FirebaseStorageService(firebaseStorageRef: mockFirebaseStorage.ref()),
        databaseService: FirebaseFirestoreService(firestoreInstance: mockFirestore));

    final newLanguagePack = LanguagePack(
        version: "draft",
        name: "English Simple",
        language: NaturalLanguage.fromCodeShort("en"),
        phrases: [
          Phrase(id: '1', text: "Hello, World!", active: true),
          Phrase(id: '2', text: "A quick brown fox", active: true),
          Phrase(id: '3', text: "Jumps over lazy fox", active: false),
        ]);
    newLanguagePack.updateVersion();
    final updateResult = await repo.updateLanguagePack(newLanguagePack);

    var succeeded = false;
    switch (updateResult) {
      case Ok<void>():
        succeeded = true;
        break;
      case Error<void>():
        break;
    }
    expect(succeeded, true);
    Result<List> fetchedListResult = await repo.getLanguagePackSummaryList();
    List<dynamic> fetchedList = [];
    switch (fetchedListResult) {
      case Ok<List>():
        fetchedList = fetchedListResult.value;
        break;
      case Error<List>():
        break;
    }

    expect(fetchedList.length, 3);
    expect(fetchedList[0].languagePackCode, "en.english-complicated");
    expect(fetchedList[1].languagePackCode, "en.kenyan-english");
    expect(fetchedList[2].languagePackCode, "en.english-simple");
    expect(fetchedList[2].version, "v1");
  });
}
