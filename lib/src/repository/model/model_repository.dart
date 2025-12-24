import '../../common/result.dart';
import '../../service/model/training_job.dart';

abstract class ModelRepository {
  Future<Result<void>> startTrainingJob(
      {required String userId,
      required String languagePackCode,
      Function(String progressStatus)? onProgress});

  Future<Result<List<TrainingJob>>> listTrainingJobs({required String userId});

  Future<Result<void>> downloadModel(
      {required String trainingId,
      required String userId,
      Function(int received, int total)? onProgress});
}
