import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_euphonia/src/common/result.dart';
import 'package:project_euphonia/src/language_pack/model/firestore_phrase.dart';
import 'package:project_euphonia/src/language_pack/model/language_pack.dart';
import 'package:project_euphonia/src/language_pack/model/language_pack_summary.dart';
import 'package:project_euphonia/src/language_pack/repository/language_pack_repo.dart';
import 'package:project_euphonia/src/language_pack/service/firestore_service.dart';
import 'package:sealed_languages/sealed_languages.dart';

void main() async {
  final mockFirebaseStorage = MockFirebaseStorage();
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
        firestoreService:
            FirestoreService(firebaseStorageRef: mockFirebaseStorage.ref()));

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
        firestoreService:
            FirestoreService(firebaseStorageRef: mockFirebaseStorage.ref()));

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

  test("Update language packs and summary list", () async {
    final repo = LanguagePackRepository(
        firestoreService:
            FirestoreService(firebaseStorageRef: mockFirebaseStorage.ref()));

    final updateResult = await repo.updateLanguagePack(LanguagePack(
        version: "draft",
        name: "English Simple",
        language: NaturalLanguage.fromCodeShort("en"),
        phrases: [
          FirestorePhrase(id: '1', text: "Hello, World!", active: true),
          FirestorePhrase(id: '2', text: "A quick brown fox", active: true),
          FirestorePhrase(id: '3', text: "Jumps over lazy fox", active: false),
        ]));

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
  });
}
