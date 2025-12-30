import '../common/result.dart';
import 'model/training_job.dart';

abstract class ModelTrainingService {
  /// Submit training request for the user.
  Future<Result<void>> trainModel(
      {required String userId,
      required String baseModel,
      required String language,
      required String data});

  /// Get status of a specific training job
  Future<Result<String>> getTrainingJob(
      {required String userId, required String trainingId});

  /// List all training jobs. If a userId is supplied, the endpoint will return
  /// training jobs for that specific user.
  /// Response list is paginated
  Future<Result<List<TrainingJob>>> listAllTrainingJobs({String? userId});

  /// Download trained model if the training is completed.
  Future<Result<void>> downloadModel(
      {required String userId, required String trainingId});

  Future<Result<void>> downloadFile(
      {required String remoteUrl,
      required String localPath,
      Function(int received, int total)? onProgress});
}
