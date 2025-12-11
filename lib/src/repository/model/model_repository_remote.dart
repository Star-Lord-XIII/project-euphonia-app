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
}
