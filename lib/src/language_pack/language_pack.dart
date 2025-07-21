import 'package:sealed_languages/sealed_languages.dart';

import 'firestore_phrase.dart';

final class LanguagePack {
  final String name;
  final NaturalLanguage language;
  final List<FirestorePhrase> phrases;

  LanguagePack(
      {required this.name, required this.language, required this.phrases});

  LanguagePack.fromJson(Map<String, Object?> json)
      : this(
            name: (json['name'] as String?) ?? "NA",
            language:
                NaturalLanguage.fromCodeShort(json['language_code'] ?? "en"),
            phrases: (json['phrases'] as List<dynamic>? ?? [])
                .map((x) => FirestorePhrase.fromJson(x))
                .toList());

  Map<String, Object?> toJson() {
    return {
      'name': name,
      'language_code': language.codeShort.toLowerCase(),
      'phrases': phrases.map((p) => p.toJson()).toList()
    };
  }
}
