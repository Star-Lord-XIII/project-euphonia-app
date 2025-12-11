import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../common/command.dart';
import '../../common/result.dart';
import '../../repository/model/model_repository.dart';
import '../../service/model/training_job.dart';

class TrainingJobHistoryViewModel extends ChangeNotifier {
  final ModelRepository _modelRepository;
  List<TrainingJob> _trainingJobs = [];

  TrainingJobHistoryViewModel({required ModelRepository modelRepository})
      : _modelRepository = modelRepository {
    initializeModel = Command0(_initializeModel)..execute();
  }

  late final Command0 initializeModel;
  List<TrainingJob> get trainingJobs => _trainingJobs;

  Future<Result<void>> _initializeModel() async {
    var errorMessage = '';
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Result.error(Exception('No current user found!'));
    }
    final trainingJobsResult =
        _modelRepository.listTrainingJobs(userId: 'user_1').then((result) {
      switch (result) {
        case Ok<List<TrainingJob>>():
          _trainingJobs = result.value;
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
