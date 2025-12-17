import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../common/result.dart';
import '../../service/model/training_job.dart';
import '../../service/model_training_service.dart';
import 'model_repository.dart';

class ModelRepositoryRemote implements ModelRepository {
  final ModelTrainingService _modelTrainingService;

  ModelRepositoryRemote({
    required ModelTrainingService modelTrainingService,
  }) : _modelTrainingService = modelTrainingService;

  List<TrainingJob>? _modelHistory;
  final Map<String, String> _trainingIdToModelDownloadURL = {};

  List<TrainingJob>? get modelHistory => _modelHistory;

  @override
  Future<Result<List<TrainingJob>>> listTrainingJobs(
      {required String userId}) async {
    if (_modelHistory != null) {
      return Result.ok(_modelHistory!);
    }
    final result =
        await _modelTrainingService.listAllTrainingJobs(userId: userId);
    if (result is Ok<List<TrainingJob>>) {
      _modelHistory = result.value;
    }
    return result;
  }

  @override
  Future<Result<void>> downloadModel(
      {required String trainingId,
      required String userId,
      Function(int received, int total)? onProgress}) async {
    final cacheKey = '$userId$trainingId';
    String downloadURL = '';
    if (_trainingIdToModelDownloadURL.containsKey(cacheKey)) {
      downloadURL = _trainingIdToModelDownloadURL[cacheKey]!;
    } else {
      final result = await _modelTrainingService.downloadModel(
          userId: userId, trainingId: trainingId);
      if (result is Ok<String>) {
        downloadURL = result.value;
        _trainingIdToModelDownloadURL[cacheKey] = downloadURL;
      }
    }
    return _downloadModel(downloadURL, onProgress);
  }

  Future<Result<void>> _downloadModel(
      String url, Function(int received, int total)? onProgress) async {
    if (url.isEmpty) {
      return Result.error(Exception('No download url found!'));
    }
    final appDocDir = await getApplicationDocumentsDirectory();
    final dirPath = '${appDocDir.absolute.path}/models';
    final path = '$dirPath/${p.basename(url)}';
    if (!Directory(dirPath).existsSync()) {
      Directory(dirPath).createSync(recursive: true);
    }
    if (!File(path).existsSync()) {
      await _modelTrainingService.downloadFile(
          remoteUrl: url, localPath: path, onProgress: onProgress);
    }
    return const Result.ok(null);
  }
}
