import '../common/result.dart';
import 'model/training_job.dart';
import 'model_training_service.dart';

class ModelTrainingServiceImpl implements ModelTrainingService {
  @override
  Future<Result<void>> trainModel(
      {required String userId,
      required String baseModel,
      required String language,
      required String data}) {
    // TODO: implement trainModel
    throw UnimplementedError();
  }

  @override
  Future<Result<TrainingJob>> getTrainingJob(
      {required String userId, required String trainingId}) {
    // TODO: implement getTrainingJob
    throw UnimplementedError();
  }

  @override
  Future<Result<List<TrainingJob>>> listAllTrainingJobs({String? userId}) {
    // TODO: implement listAllTrainingJobs
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> downloadModel(
      {required String userId, required String trainingId}) {
    // TODO: implement downloadModel
    throw UnimplementedError();
  }
}
