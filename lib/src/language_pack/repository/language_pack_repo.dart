import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../common/result.dart';
import '../model/language_pack.dart';
import '../model//language_pack_summary.dart';
import '../service/firestore_service.dart';

final class LanguagePackRepository {
  final FirestoreService firestoreService;
  final _log = Logger('language_pack.LanguagePackRepository');

  LanguagePackRepository({required this.firestoreService});

  Future<Result<List<LanguagePackSummary>>> getLanguagePackSummaryList() async {
    final languagePackSummaryPath = 'phrases/language_packs.json';
    final currentLanguagePackSummariesResult =
        await firestoreService.readFile(path: languagePackSummaryPath);
    switch (currentLanguagePackSummariesResult) {
      case Ok<String>():
        break;
      case Error<void>():
        _log.warning('Error reading current language pack summaries list');
        return Result.error(
            Exception('Error reading current language pack summaries list'));
    }
    final languagePackSummaryList = convertStringToLanguagePackListSummaries(
        currentLanguagePackSummariesResult.value);
    return Result.ok(languagePackSummaryList);
  }

  @visibleForTesting
  List<LanguagePackSummary> convertStringToLanguagePackListSummaries(
      String languagePackListJson) {
    final listOfMaps = jsonDecode(languagePackListJson);
    List<LanguagePackSummary> languagePackSummaryList = [];
    for (final map in listOfMaps) {
      languagePackSummaryList.add(LanguagePackSummary.fromJson(
          map));
    }
    return languagePackSummaryList;
  }

  Future<Result<void>> updateLanguagePack(LanguagePack languagePack) async {
    languagePack.updateVersion();

    _log.fine('Updating language pack version to ${languagePack.version}');
    final updatedLanguagePackPath =
        'phrases/${languagePack.languagePackCode}.${languagePack.version}.json';
    final writeResult = await firestoreService.writeFile(
        path: updatedLanguagePackPath,
        content: jsonEncode(languagePack.toActivePhrasesJson()));
    switch (writeResult) {
      case Ok<void>():
        break;
      case Error<void>():
        _log.warning('Error updating languagePack phrases file');
        return writeResult;
    }

    _log.fine('Fetching language pack summary');
    final Result<List> currentLanguagePackSummariesResult =
        await getLanguagePackSummaryList();
    List<dynamic> fetchedList = [];
    switch (currentLanguagePackSummariesResult) {
      case Ok<List>():
        fetchedList = currentLanguagePackSummariesResult.value;
        break;
      case Error<void>():
        _log.warning('Error reading current language pack summaries list');
        return currentLanguagePackSummariesResult;
    }
    List<LanguagePackSummary> languageSummaryList =
        List<LanguagePackSummary>.from(fetchedList);
    final isLanguagePackNew = languageSummaryList
        .where((x) => x.languagePackCode == languagePack.languagePackCode)
        .isEmpty;

    _log.fine('Update language pack summary list in memory');
    var updatedLanguageSummaryList = languageSummaryList.map((x) {
      if (x.languagePackCode == languagePack.languagePackCode) {
        return LanguagePackSummary.fromJson(languagePack.toSummaryJson());
      }
      return x;
    }).toList();

    if (isLanguagePackNew) {
      updatedLanguageSummaryList.add(LanguagePackSummary.fromJson(languagePack.toSummaryJson()));
    }

    _log.fine('Update language pack summary list in Firebase Storage');
    final languagePackSummaryPath = 'phrases/language_packs.json';
    final updateResult = await firestoreService.writeFile(
        path: languagePackSummaryPath,
        content: jsonEncode(updatedLanguageSummaryList));
    switch (updateResult) {
      case Ok<void>():
        break;
      case Error<void>():
        _log.warning('Error update language pack summaries list');
        return updateResult;
    }
    _log.fine('Language pack updated successfully to ${languagePack.version}');
    return const Result.ok(null);
  }
}
