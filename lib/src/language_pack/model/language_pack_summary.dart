import 'package:sealed_languages/sealed_languages.dart';

final class LanguagePackSummary {
  final String version;
  final String name;
  final String languagePackCode;
  final NaturalLanguage language;
  final int phrasesCount;

  LanguagePackSummary(
      {required this.version,
      required this.name,
      required this.language,
      required this.languagePackCode,
      required this.phrasesCount});

  LanguagePackSummary.fromJson(Map<String, Object?> json)
      : this(
            version: (json['version'] as String),
            name: (json['name'] as String),
            languagePackCode: (json['language_pack_code'] as String),
            language:
                NaturalLanguage.fromCodeShort(json['language_code'] ?? "en"),
            phrasesCount: (json['phrases_count'] as int));

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'name': name,
      'language_pack_code': languagePackCode,
      'language_code': language.codeShort.toLowerCase(),
      'phrases_count': phrasesCount
    };
  }
}
