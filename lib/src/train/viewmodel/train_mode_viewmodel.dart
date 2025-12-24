import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../common/command.dart';
import '../../common/result.dart';
import '../../repository/model/model_repository.dart';

class TrainModeViewModel extends ChangeNotifier {
  final ModelRepository _modelRepository;

  bool _training = false;
  String _progressStatus = '';

  TrainModeViewModel({required ModelRepository modelRepository})
      : _modelRepository = modelRepository {
    train = Command0(_train);
  }

  late final Command0 train;
  bool get training => _training;
  String get progressStatus => _progressStatus;

  Future<Result<void>> _train() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Result.error(Exception('No current user found!'));
    }
    _training = true;
    notifyListeners();
    final result = await _modelRepository.startTrainingJob(
        userId: userId,
        languagePackCode: 'en.english-complicated',
        onProgress: (status) {
          _progressStatus = status;
          notifyListeners();
        });
    _training = false;
    notifyListeners();
    return result;
  }
}
