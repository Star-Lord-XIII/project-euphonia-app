import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../common/result.dart';
import 'model/training_job.dart';
import 'model_training_service.dart';

class ModelTrainingServiceImpl implements ModelTrainingService {
  static const String _backendEndpoint = 'BACKEND_END_POINT';
  static const String _token = 'TOKEN';
  static const String _trainModePath = '/model/train';
  static const String _listAllTrainingJobsPath = '/model/list_all';
  static const String _listAllForUserTrainingJobsPath = '/model/list_for_user';
  static const String _downloadModelPath = '/download';

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
  Future<Result<List<TrainingJob>>> listAllTrainingJobs(
      {String? userId}) async {
    final uri = Uri.parse(
        '$_backendEndpoint${userId == null
            ? _listAllTrainingJobsPath
            : '$_listAllForUserTrainingJobsPath?user_id=$userId'}');
    final Map<String, String>? headers = userId == null
        ? null
        : {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: "Bearer $_token"
          };
    final http.Response response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

    // error
    if (response.statusCode != 200) {
      var errorMessage = 'Something went wrong fetching training jobs';
      if (responseBody.containsKey('detail')) {
        errorMessage = jsonEncode(responseBody['detail']);
      }
      return Result.error(Exception(errorMessage));
    }

    // success
    List<TrainingJob> trainingJobs = [];
    if (responseBody.containsKey('jobs')) {
      final jobsVal = responseBody['jobs'] as List<dynamic>;
      trainingJobs = jobsVal.map((jv) => TrainingJob.fromMap(jv)).toList();
    }
    return Result.ok(trainingJobs);
  }

  @override
  Future<Result<void>> downloadModel(
      {required String userId, required String trainingId}) {
    // TODO: implement downloadModel
    throw UnimplementedError();
  }
}
