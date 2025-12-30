import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../common/result.dart';
import 'model/training_job.dart';
import 'model_training_service.dart';

class ModelTrainingServiceImpl implements ModelTrainingService {
  static const String _backendEndpoint = 'MODEL_TRAINING_BACKEND';
  static const String _token = 'MODEL_TRAINING_BACKEND_TOKEN';
  static const String _trainModePath = '/model/train';
  static const String _listAllTrainingJobsPath = '/model/list_all';
  static const String _listAllForUserTrainingJobsPath = '/model/list_for_user';
  static const String _listJobForUserPath = '/model/list_job';
  static const String _downloadModelPath = '/model/download';

  @override
  Future<Result<void>> trainModel(
      {required String userId,
      required String baseModel,
      required String language,
      required String data}) async {
    final uri = Uri.parse('$_backendEndpoint$_trainModePath');
    final request = http.MultipartRequest('POST', uri);
    request.headers[HttpHeaders.contentTypeHeader] = 'application/json';
    request.headers[HttpHeaders.authorizationHeader] = "Bearer $_token";

    request.fields['user_id'] = userId;
    request.fields['base_model'] = baseModel;
    request.fields['language'] = language;
    request.fields['audio_type'] = 'wav';

    request.files.add(await http.MultipartFile.fromPath('data', data));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    // error
    if (response.statusCode != 200) {
      var errorMessage = 'Something went wrong starting a training jobs';
      return Result.error(Exception(errorMessage));
    }

    return Result.ok(null);
  }

  @override
  Future<Result<String>> getTrainingJob(
      {required String userId, required String trainingId}) async {
    final uri = Uri.parse(
        '$_backendEndpoint$_listJobForUserPath?user_id=$userId&training_id=$trainingId');
    final Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "Bearer $_token"
    };
    final http.Response response = await http.get(uri, headers: headers);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      var errorMessage = 'Something went wrong fetching training job';
      if (responseBody.containsKey('detail')) {
        errorMessage = jsonEncode(responseBody['detail']);
      }
      return Result.error(Exception(errorMessage));
    }
    return Result.ok(response.body);
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

    Map<String, dynamic> responseBody = {};
    dynamic error;
    final http.Response response = await http
        .get(uri, headers: headers)
        .then((value) => value, onError: (e) {
      error = e;
      return http.Response('{"detail": "Unable to reach server!"}', 500);
    });
    responseBody = jsonDecode(response.body) as Map<String, dynamic>;

    // error
    if (response.statusCode != 200 || error != null) {
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
