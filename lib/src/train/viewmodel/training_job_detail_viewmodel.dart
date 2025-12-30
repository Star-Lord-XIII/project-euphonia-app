import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../common/command.dart';
import '../../common/result.dart';
import '../../repository/model/model_repository.dart';
import '../../service/model/training_data.dart';

class TrainingJobDetailViewModel extends ChangeNotifier {
  final ModelRepository _modelRepository;
  final String _trainingId;
  String get trainingId => _trainingId;
  late final Command0 initializeModel;
  late TrainingData _trainingData;
  TrainingData get trainingData => _trainingData;

  TrainingJobDetailViewModel(
      {required ModelRepository modelRepository, required String trainingId})
      : _modelRepository = modelRepository,
        _trainingId = trainingId {
    initializeModel = Command0(_initializeModel)..execute();
  }

  Future<Result<void>> _initializeModel() async {
    var errorMessage = '';
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Result.error(Exception('No current user found!'));
    }
    final trainingJobsResult = _modelRepository
        .getTrainingJobDetails(userId: userId, trainingId: _trainingId)
        .then((result) {
      switch (result) {
        case Ok<String>():
          final response = result.value;
          final responseMap = jsonDecode(response);
          final String baseModel =
              responseMap['training_hparams']['base_model'];
          final String language = responseMap['training_hparams']['language'];
          final int utteranceCount = responseMap['data']['num_examples'];
          final double finalWer =
              responseMap['result']['final_metrics']['eval_wer'];
          _trainingData = TrainingData(
              trainingExamples: utteranceCount,
              baseModel: baseModel,
              language: language,
              wordErrorRate: finalWer);
        case Error():
          errorMessage += '${result.error}\n';
      }
    });

    await Future.wait([trainingJobsResult]);
    notifyListeners();
    if (errorMessage.isNotEmpty) {
      return Result.error(Exception(errorMessage));
    }
    return const Result.ok(null);
  }
}
