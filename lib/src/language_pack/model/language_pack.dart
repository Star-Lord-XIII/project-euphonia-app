import 'package:sealed_languages/sealed_languages.dart';

import 'firestore_phrase.dart';

///
/// LanguagePack document in Firestore.
///
final class LanguagePack {
  // Version of the language pack.
  // Goes "draft", "v1", "v2", ...
  String version;

  // Human readable name of the language pack
  final String name;

  // Intermediate instance of language to list languages to/from language codes.
  final NaturalLanguage language;

  // List of phrases
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

  // Just list active phrases phrases. To be used in saving a language-pack
  // as json file in storage.
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

  // Summarize a language pack to be added to a list of language-packs. To be
  // displayed during language-pack selection.
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
}
