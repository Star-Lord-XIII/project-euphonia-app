import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../common/command.dart';
import '../../common/result.dart';
import '../../repository/model/model_repository.dart';
import '../../service/model/training_job.dart';

class TrainingJobHistoryViewModel extends ChangeNotifier {
  final ModelRepository _modelRepository;
  List<TrainingJob> _trainingJobs = [];
  final Map<String, DownloadStatus> _modelDownloadStatus = {};
  final Map<String, DownloadProgress> _modelDownloadProgress = {};

  TrainingJobHistoryViewModel({required ModelRepository modelRepository})
      : _modelRepository = modelRepository {
    initializeModel = Command0(_initializeModel)..execute();
    downloadModel = Command1(_downloadModel);
  }

  late final Command0 initializeModel;
  late final Command1<void, String> downloadModel;
  List<TrainingJob> get trainingJobs => _trainingJobs;

  Future<Result<void>> _initializeModel() async {
    var errorMessage = '';
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Result.error(Exception('No current user found!'));
    }
    final trainingJobsResult =
        _modelRepository.listTrainingJobs(userId: userId).then((result) {
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

  DownloadStatus getModelDownloadStatus(String trainingId) {
    return _modelDownloadStatus[trainingId] ?? DownloadStatus.notStarted;
  }

  DownloadProgress? getModelDownloadProgress(String trainingId) {
    return _modelDownloadProgress[trainingId];
  }

  Future<Result<void>> _downloadModel(String trainingId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Result.error(Exception('No current user found!'));
    }
    _modelDownloadStatus[trainingId] = DownloadStatus.inProgress;
    notifyListeners();
    final result = await _modelRepository.downloadModel(
        trainingId: trainingId,
        userId: userId,
        onProgress: (downloaded, total) {
          _modelDownloadProgress[trainingId] =
              DownloadProgress(downloaded: downloaded, total: total);
          notifyListeners();
        });
    if (result is Ok) {
      _modelDownloadStatus[trainingId] = DownloadStatus.completed;
    } else {
      _modelDownloadStatus[trainingId] = DownloadStatus.interrupted;
    }
    notifyListeners();
    return result;
  }
}

enum DownloadStatus { notStarted, inProgress, interrupted, completed }

class DownloadProgress {
  final int downloaded;
  final int total;

  const DownloadProgress({
    required this.downloaded,
    required this.total,
  });
}
