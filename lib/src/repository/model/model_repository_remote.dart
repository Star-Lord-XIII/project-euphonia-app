import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/result.dart';
import '../../language_pack/model/language_pack.dart';
import '../../service/model/training_job.dart';
import '../../service/model_training_service.dart';
import '../../service/remote_data/remote_data_service.dart';
import 'model_repository.dart';

class ModelRepositoryRemote implements ModelRepository {
  final ModelTrainingService _modelTrainingService;
  final RemoteDataService _remoteDataService;

  ModelRepositoryRemote(
      {required ModelTrainingService modelTrainingService,
      required RemoteDataService remoteDataService})
      : _modelTrainingService = modelTrainingService,
        _remoteDataService = remoteDataService;

  List<TrainingJob>? _modelHistory;
  final Map<String, String> _trainingIdToModelDownloadURL = {};
  final Map<String, String> _trainingIdToTrainingJobData = {};

  List<TrainingJob>? get modelHistory => _modelHistory;

  @override
  Future<Result<List<TrainingJob>>> listTrainingJobs(
      {required String userId}) async {
    return _modelTrainingService.listAllTrainingJobs(userId: userId);
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

  @override
  Future<Result<void>> startTrainingJob(
      {required String userId,
      required String languagePackCode,
      Function(String progressStatus)? onProgress}) async {
    final utteranceCountForTrainingCacheKey =
        '$userId-$languagePackCode-utt-count-key';
    final prefs = await SharedPreferences.getInstance();

    final downloadResult = await _remoteDataService.downloadAllUtterances(
        userUid: userId,
        languagePackCode: languagePackCode,
        onProgress: (downloaded, total) {
          if (onProgress != null) {
            onProgress('Downloading $downloaded/$total utterances');
          }
        });
    if (onProgress != null) {
      onProgress('Downloading Language Pack');
    }
    final languagePackResult = await _remoteDataService.getMasterLanguagePack(
        languagePackCode: languagePackCode);

    if (downloadResult is Error) {
      return downloadResult;
    } else if (languagePackResult is Error) {
      return languagePackResult;
    }
    if (onProgress != null) {
      onProgress('Language Pack downloaded');
    }

    final appDocDir = await getApplicationDocumentsDirectory();
    final downloadDir =
        Directory('${appDocDir.path}/$userId/$languagePackCode');
    var downloadedUtterances = [];

    if (onProgress != null) {
      onProgress('Starting to build archive');
    }
    final archive = Archive();

    if (downloadDir.existsSync()) {
      for (final file in downloadDir.listSync()) {
        if (!file.path.endsWith('.wav')) {
          continue;
        }
        final fileNameWExt = p.basename(file.path);
        final bytes = await File(file.path).readAsBytes();
        archive.addFile(ArchiveFile(fileNameWExt, bytes.length, bytes));
        final fileName = fileNameWExt.split('.').first;
        downloadedUtterances.add(fileName);
      }
    }
    if (downloadedUtterances.length < 20) {
      if (onProgress != null) {
        onProgress(
            'You need at least 20 utterances to train a personalized model.');
      }
      return Result.error(Exception(
          'You need at least 20 utterances to train a personalized model.'));
    }
    final currentUtteranceCount =
        prefs.getInt(utteranceCountForTrainingCacheKey) ?? 0;
    if (currentUtteranceCount == downloadedUtterances.length) {
      if (onProgress != null) {
        onProgress('No new utterances found to start new training task');
      }
      return Result.error(
          Exception('There are no new utterances to train a model'));
    }

    if (languagePackResult is Ok<LanguagePack>) {
      for (final phrase in languagePackResult.value.phrases) {
        if (downloadedUtterances.contains(phrase.id)) {
          final textFilePath = '${downloadDir.path}/${phrase.id}.txt';
          await File(textFilePath).writeAsString(phrase.text);
          final bytes = await File(textFilePath).readAsBytes();
          archive.addFile(ArchiveFile('${phrase.id}.txt', bytes.length, bytes));
        }
      }
    }

    final compressedGZipFilePath =
        '${appDocDir.path}/$userId/$languagePackCode.tar.gz';
    if (File(compressedGZipFilePath).existsSync()) {
      File(compressedGZipFilePath).deleteSync();
    }
    final tarEncoder = TarEncoder();
    final tarBytes = tarEncoder.encodeBytes(archive);
    final gzipEncoder = GZipEncoder();
    final gzipBytes = gzipEncoder.encodeBytes(tarBytes);
    final compressedFile = File(compressedGZipFilePath);
    await compressedFile.writeAsBytes(gzipBytes);
    if (onProgress != null) {
      onProgress('Archive created at $compressedGZipFilePath');
    }

    final trainingJobResult = await _modelTrainingService.trainModel(
        userId: userId,
        baseModel: 'openai/whisper-tiny',
        language: languagePackCode.split('.').first,
        data: compressedGZipFilePath);
    if (trainingJobResult is Ok) {
      if (onProgress != null) {
        onProgress('Training Job requested');
      }
      prefs.setInt(
          utteranceCountForTrainingCacheKey, downloadedUtterances.length);
      _modelHistory?.clear();
      _modelHistory = null;
    }
    if (trainingJobResult is Error) {
      if (onProgress != null) {
        onProgress(trainingJobResult.error.toString());
      }
    }
    return const Result.ok(null);
  }

  @override
  Future<Result<String>> getTrainingJobDetails(
      {required String userId, required String trainingId}) async {
    if (_trainingIdToTrainingJobData.containsKey(trainingId)) {
      return Result.ok(_trainingIdToTrainingJobData[trainingId]!);
    }
    final result = await _modelTrainingService.getTrainingJob(
        userId: userId, trainingId: trainingId);
    if (result is Ok<String>) {
      _trainingIdToTrainingJobData[trainingId] = result.value;
    }
    return result;
  }
}
