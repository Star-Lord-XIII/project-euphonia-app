import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:sealed_languages/sealed_languages.dart';

import 'firestore_phrase.dart';

final class LanguagePack {
  String version;
  final String name;
  final NaturalLanguage language;
  final List<FirestorePhrase> phrases;

  LanguagePack(
      {required this.version,
      required this.name,
      required this.language,
      required this.phrases});

  LanguagePack.fromJson(Map<String, Object?> json)
      : this(
            version: (json['version'] as String?) ?? "draft",
            name: (json['name'] as String?) ?? "NA",
            language:
                NaturalLanguage.fromCodeShort(json['language_code'] ?? "en"),
            phrases: (json['phrases'] as List<dynamic>? ?? [])
                .map((x) => FirestorePhrase.fromJson(x))
                .toList());

  Map<String, Object?> toJson() {
    return {
      'version': version,
      'name': name,
      'language_code': language.codeShort.toLowerCase(),
      'phrases': phrases.map((p) => p.toJson()).toList()
    };
  }

  Map<String, Object?> toActivePhrasesJson() {
    return {
      'version': version,
      'name': name,
      'language_code': language.codeShort.toLowerCase(),
      'phrases': phrases
          .where((p) => p.active)
          .map((p) => p.toJsonWithoutActive())
          .toList()
    };
  }

  Map<String, Object?> toSummaryJson() {
    return {
      'version': version,
      'name': name,
      'language_pack_code': languagePackCode,
      'language_code': language.codeShort.toLowerCase(),
      'phrases_count': phrases.where((p) => p.active).toList().length
    };
  }

  void updateVersion() {
    if (version == 'draft') {
      version = 'v1';
    } else {
      var versionNumber = int.parse(version.substring(1));
      version = 'v${versionNumber + 1}';
    }
  }

  String get languagePackCode {
    return "${language.codeShort.toLowerCase()}.${name.trim().toLowerCase().split(' ').join('-')}";
  }

  Future<void> publishToCloudStorage() async {
    final storageRef = FirebaseStorage.instance.ref();
    final jsonRef =
        storageRef.child('phrases/${languagePackCode}.${version}.json');
    final languagePackList = storageRef.child('phrases/language_packs.json');
    try {
      Uint8List? listData = await languagePackList.getData();
      if (listData != null) {
        String languagePackListContents = Utf8Decoder().convert(listData);
        List<dynamic> languagePackMapList =
            jsonDecode(languagePackListContents);
        if (version == "v1") {
          languagePackMapList.add(toSummaryJson());
          languagePackList.putString(jsonEncode(languagePackMapList));
        } else {
          for (final Map<String, dynamic> languagePack in languagePackMapList) {
            if (languagePack['language_pack_code'] == languagePackCode) {
              languagePack['version'] = version;
            }
          }
          languagePackList.putString(jsonEncode(languagePackMapList));
        }
      }
    } on FirebaseException catch (e) {
      developer.log('ERROR: ${e.message}');
      languagePackList.putString(jsonEncode([toSummaryJson()]));
    }
    jsonRef.putString(jsonEncode(toActivePhrasesJson()));
  }
}
