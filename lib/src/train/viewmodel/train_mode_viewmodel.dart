import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../common/command.dart';
import '../../common/result.dart';
import '../../language_pack/model/language_pack_summary.dart';
import '../../language_pack/repository/language_pack_repo.dart';
import '../../repository/model/model_repository.dart';

class TrainModeViewModel extends ChangeNotifier {
  final ModelRepository _modelRepository;
  final LanguagePackRepository _languagePackRepository;

  bool _training = false;
  String _progressStatus = '';
  List<LanguagePackSummary> _languagePackSummary = [];
  List<LanguagePackSummary> get languagePackSummary => _languagePackSummary;
  String _selectedLanguagePackCode = '';

  TrainModeViewModel(
      {required ModelRepository modelRepository,
      required LanguagePackRepository languagePackRepository})
      : _modelRepository = modelRepository,
        _languagePackRepository = languagePackRepository {
    initializeModel = Command0(_initialize)..execute();
    train = Command0(_train);
  }

  late final Command0 initializeModel;
  late final Command0 train;
  bool get training => _training;
  String get progressStatus => _progressStatus;

  Future<Result<void>> _initialize() async {
    var errorMessage = '';
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Result.error(Exception('No current user found!'));
    }
    final languagePackSummaryResult =
        _languagePackRepository.getLanguagePackSummaryList().then((result) {
      switch (result) {
        case Ok<List<LanguagePackSummary>>():
          _languagePackSummary = result.value
              .where((lps) =>
                  !(lps.name.contains('image') || lps.name.contains('picture')))
              .toList();
        case Error():
          errorMessage += '${result.error}\n';
      }
    });

    await Future.wait([languagePackSummaryResult]);
    notifyListeners();
    if (errorMessage.isNotEmpty) {
      return Result.error(Exception(errorMessage));
    }
    return const Result.ok(null);
  }

  void selectLanguagePackCode(String languagePackCode) {
    _selectedLanguagePackCode = languagePackCode;
  }

  Future<Result<void>> _train() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _progressStatus = 'No current user found!';
      notifyListeners();
      return Result.error(Exception('No current user found!'));
    }
    if (_selectedLanguagePackCode.isEmpty) {
      _progressStatus =
          'No language pack selected. Please select one before proceeding!';
      notifyListeners();
      return Result.error(Exception(
          'No language pack selected. Please select one before proceeding!'));
    }
    _training = true;
    notifyListeners();
    final result = await _modelRepository.startTrainingJob(
        userId: userId,
        languagePackCode: _selectedLanguagePackCode,
        onProgress: (status) {
          _progressStatus = status;
          notifyListeners();
        });
    _training = false;
    notifyListeners();
    return result;
  }
}
