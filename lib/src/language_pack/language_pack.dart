import 'package:sealed_languages/sealed_languages.dart';

final class LanguagePack {
  final String name;
  final String code;
  final NaturalLanguage language;

  LanguagePack(
      {required this.name, required this.code, required this.language});
}
