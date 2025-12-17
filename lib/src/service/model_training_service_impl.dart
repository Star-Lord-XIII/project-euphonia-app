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
  static const String _downloadModelPath = '/model/download';

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
        '$_backendEndpoint${userId == null ? _listAllTrainingJobsPath : '$_listAllForUserTrainingJobsPath?user_id=$userId'}');
    final Map<String, String> headers = {
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
  Future<Result<String>> downloadModel(
      {required String userId, required String trainingId}) async {
    final uri = Uri.parse(
        '$_backendEndpoint$_downloadModelPath?training_id=$trainingId&user_id=$userId');
    final Map<String, String>? headers = {
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
    return Result.ok(responseBody['download_url']);
  }

  @override
  Future<Result<void>> downloadFile(
      {required String remoteUrl,
      required String localPath,
      Function(int received, int total)? onProgress}) async {
    try {
      final request = http.Request('GET', Uri.parse(remoteUrl));
      final response = await request.send();

      if (response.statusCode != 200) {
        return Result.error(
            Exception('Error: Status code ${response.statusCode}'));
      }

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;

      final file = File(localPath);
      final sink = file.openWrite();

      await for (var chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;

        if (onProgress != null && totalBytes > 0) {
          onProgress(receivedBytes, totalBytes);
        }
      }

      await sink.close();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Error downloading file: $e'));
    }
  }
}
