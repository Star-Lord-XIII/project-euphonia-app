import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:logging/logging.dart';

import '../../common/result.dart';
import 'file_storage_service.dart';

final class FirebaseStorageService extends FileStorageService {
  final _log = Logger('language_pack.FirebaseStorageService');

  final Reference firebaseStorageRef;

  FirebaseStorageService({required this.firebaseStorageRef});

  @override
  Future<Result<String>> readFile({required String path}) async {
    final storageRef = firebaseStorageRef.child(path);
    try {
      Uint8List? data = await storageRef.getData();
      if (data == null) {
        throw Exception("File not found at $path!");
      }
      String content = Utf8Decoder().convert(data);
      return Result.ok(content);
    } on FirebaseException catch (e) {
      _log.warning(e);
      return Result.error(e);
    } on Exception catch (e) {
      _log.warning(e);
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> writeFile({required String path,
                                  required String content}) async {
    final storageRef = firebaseStorageRef.child(path);
    try {
      await storageRef.putString(content);
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      _log.warning(e);
      return Result.error(e);
    }
  }
}