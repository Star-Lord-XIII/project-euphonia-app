import 'package:flutter/material.dart';
import 'package:project_euphonia/src/language_pack/model/language_pack.dart';
import 'package:project_euphonia/src/language_pack/model/language_pack_summary.dart';

final class LanguagePackCatalogModel extends ChangeNotifier {
  List<LanguagePackSummary> _languagePackSummaryList = [];
  LanguagePack? _languagePack;

  List<LanguagePackSummary> get languagePackSummaryList =>
      _languagePackSummaryList;
  LanguagePack? get languagePack => _languagePack;

  LanguagePackCatalogModel();

  void updateLanguagePack(LanguagePack updatedLanguagePack) {
    _languagePack = updatedLanguagePack;
    notifyListeners();
  }

  void updateLanguagePackSummaryList(List<LanguagePackSummary> lpSummaryList) {
    _languagePackSummaryList = lpSummaryList;
    notifyListeners();
  }
}
