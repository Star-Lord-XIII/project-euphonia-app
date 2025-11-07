import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import '../../common/result.dart';
import '../model/language_pack.dart';
import '../model/language_pack_summary.dart';
import '../model/phrase.dart';
import '../service/database_service.dart';
import '../service/file_storage_service.dart';

final class LanguagePackRepository {
  final FileStorageService _fileStorageService;
  final DatabaseService _databaseService;
  final languagePackTableName = 'language_packs';
  final _log = Logger('language_pack.LanguagePackRepository');

  LanguagePackRepository(
      {required FileStorageService fileStorageService,
      required DatabaseService databaseService})
      : _databaseService = databaseService,
        _fileStorageService = fileStorageService;

  Future<Result<List<LanguagePackSummary>>> getLanguagePackSummaryList() async {
    final languagePackSummaryPath = 'phrases/$languagePackTableName.json';
    final currentLanguagePackSummariesResult =
        await _fileStorageService.readFile(path: languagePackSummaryPath);
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

  Future<Result<void>> addLanguagePack(
      {required LanguagePack languagePack}) async {
    _log.finer('Create new language pack: ${languagePack.languagePackCode}');
    final insertResult = await _databaseService.insert(
        table: languagePackTableName,
        id: languagePack.languagePackCode,
        newValue: languagePack.toJson());
    switch (insertResult) {
      case Ok<void>():
        break;
      case Error<void>():
        final errorMessage =
            'Error creating language pack with id: ${languagePack.languagePackCode}';
        _log.warning(errorMessage);
        return Result.error(Exception(errorMessage));
    }
    return const Result.ok(null);
  }

  Future<Result<LanguagePack>> getLanguagePack(
      {required String languagePackId}) async {
    _log.finer('Reading Language Pack by id: $languagePackId');
    final languagePackResult = await _databaseService.getRow(
        table: languagePackTableName, id: languagePackId);
    switch (languagePackResult) {
      case Ok<Map<String, dynamic>>():
        break;
      case Error<void>():
        final errorMessage =
            'Error reading language pack with id: $languagePackId';
        _log.warning(errorMessage);
        return Result.error(Exception(errorMessage));
    }
    final languagePack = LanguagePack.fromJson(languagePackResult.value);
    return Result.ok(languagePack);
  }

  @visibleForTesting
  List<LanguagePackSummary> convertStringToLanguagePackListSummaries(
      String languagePackListJson) {
    final listOfMaps = jsonDecode(languagePackListJson);
    List<LanguagePackSummary> languagePackSummaryList = [];
    for (final map in listOfMaps) {
      languagePackSummaryList.add(LanguagePackSummary.fromJson(map));
    }
    return languagePackSummaryList;
  }

  Future<Result<void>> updateLanguagePack({required String languagePackId,
    String? version, List<Phrase>? phrases}) async {
    Map<String, dynamic> updatedValues = {};
    if (version != null) {
      updatedValues['version'] = version;
    }
    if (phrases != null && phrases.isNotEmpty) {
      updatedValues['phrases'] = phrases.map((p) => p.toJson()).toList();
    }
    final result = await _databaseService.update(table: languagePackTableName,
        id: languagePackId, updatedValues: updatedValues);
    return result;
  }

  Future<Result<void>> publishLanguagePack(LanguagePack languagePack) async {
    _log.fine('Updating language pack version to ${languagePack.version}');
    updateLanguagePack(languagePackId: languagePack.languagePackCode,
        version: languagePack.version);
    final updatedLanguagePackPath =
        'phrases/${languagePack.languagePackCode}.${languagePack.version}.json';
    final writeResult = await _fileStorageService.writeFile(
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
      updatedLanguageSummaryList
          .add(LanguagePackSummary.fromJson(languagePack.toSummaryJson()));
    }

    _log.fine('Update language pack summary list in Firebase Storage');
    final languagePackSummaryPath = 'phrases/$languagePackTableName.json';
    final updateResult = await _fileStorageService.writeFile(
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
