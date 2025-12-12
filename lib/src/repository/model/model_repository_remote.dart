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
  Map<String, String> _trainingIdToModelDownloadURL = {};

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
      {required String trainingId, required String userId}) async {
    final cacheKey = '$userId$trainingId';
    String downloadURL = '';
    if (_trainingIdToModelDownloadURL.containsKey(cacheKey)) {
      downloadURL = _trainingIdToModelDownloadURL[cacheKey]!;
    } else {
      final result = await _modelTrainingService.downloadModel(userId: userId, trainingId: trainingId);
      if (result is Ok<String>) {
        downloadURL = result.value;
        _trainingIdToModelDownloadURL[cacheKey] = downloadURL;
      }
    }
    return _downloadModel(downloadURL);
  }

  Future<Result<void>> _downloadModel(String url) async {
    // TODO: download on-device model.
    print('DOWNLOAD>>>>>>>>>>>>>>>>> $url');
    return const Result.ok(null);
  }
}
