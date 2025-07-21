import 'package:sealed_languages/sealed_languages.dart';

final class LanguagePack {
  final String name;
  final String code;
  final NaturalLanguage language;

  LanguagePack(
      {required this.name, required this.code, required this.language});

  LanguagePack.fromJson(Map<String, Object?> json)
      : this(
            name: (json['name'] as String?) ?? "NA",
            code: (json['language_code'] as String?) ?? "en",
            language:
                NaturalLanguage.fromCodeShort(json['language_code'] ?? "en"));

  Map<String, Object?> toJson() {
    return {'name': name, 'language_code': language.codeShort.toLowerCase()};
  }
}
