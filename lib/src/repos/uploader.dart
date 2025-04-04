import 'dart:async';

import 'package:flutter/material.dart';

import '../modes/upload_status.dart';

final class Uploader extends ChangeNotifier {
  UploadStatus _uploadStatus = UploadStatus.notStarted;
  Timer? _timer;

  Icon get uploadIcon {
    switch (_uploadStatus) {
      case UploadStatus.notStarted:
        return const Icon(Icons.cloud_upload, color: Colors.transparent);
      case UploadStatus.started:
        return const Icon(Icons.cloud_upload, color: Colors.blue);
      case UploadStatus.completed:
        return const Icon(Icons.cloud_done, color: Colors.green);
      case UploadStatus.interrupted:
        return const Icon(Icons.cloud_off, color: Colors.red);
    }
  }

  bool get showProgressIndicator => (_uploadStatus == UploadStatus.started);

  bool get showUploadProgressIcon {
    switch (_uploadStatus) {
      case UploadStatus.notStarted:
        return false;
      case UploadStatus.started:
        return true;
      case UploadStatus.completed:
        return true;
      case UploadStatus.interrupted:
        return true;
    }
  }

  void updateStatus({required UploadStatus status}) {
    _uploadStatus = status;
    notifyListeners();
    if (_uploadStatus == UploadStatus.completed) {
      _timer = Timer(const Duration(seconds: 1, milliseconds: 500), () {
        _uploadStatus = UploadStatus.notStarted;
        notifyListeners();
      });
    } else {
      _timer?.cancel();
    }
  }
}
