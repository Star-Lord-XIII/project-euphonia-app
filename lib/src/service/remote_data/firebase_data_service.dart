import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../../common/result.dart';
import '../../language_pack/model/language_pack.dart';
import 'remote_data_service.dart';

class FirebaseDataService implements RemoteDataService {
  final FirebaseFirestore _firestore;
  final Reference _storageRef;

  const FirebaseDataService({
    required FirebaseFirestore firestore,
    required Reference storageRef,
  })  : _firestore = firestore,
        _storageRef = storageRef;

  @override
  Future<Result<void>> downloadAllUtterances(
      {required String userUid,
      required String languagePackCode,
      Function(int received, int total)? onProgress}) async {
    final utterancesRef = _storageRef.child('$userUid/$languagePackCode');
    final ListResult result = await utterancesRef.listAll();

    final docDir = await getApplicationDocumentsDirectory();
    final String localUserDir = '${docDir.path}/$userUid/$languagePackCode';
    if (!Directory(localUserDir).existsSync()) {
      Directory(localUserDir).createSync(recursive: true);
    }

    final wavFiles = result.items.where((f) => f.name.endsWith('.wav'));
    int downloaded = 0;
    for (final fileRef in wavFiles) {
      final localFile = File('$localUserDir/${fileRef.name}');
      if (localFile.existsSync()) {
        if (onProgress != null) {
          downloaded += 1;
          onProgress(downloaded, wavFiles.length);
        }
        continue;
      }
      await fileRef.writeToFile(localFile);
      if (onProgress != null) {
        downloaded += 1;
        onProgress(downloaded, wavFiles.length);
      }
    }

    return Result.ok(null);
  }

  @override
  Future<Result<LanguagePack>> getMasterLanguagePack(
      {required String languagePackCode}) {
    final languagePackRef =
        _firestore.collection('language_packs').doc(languagePackCode);
    return languagePackRef.get().then((doc) {
      final data = doc.data();
      if (data == null) {
        return Result.error(
          Exception('Language pack not found at ${languagePackRef.path}'),
        );
      }
      final languagePack = LanguagePack.fromJson(data);
      return Result.ok(languagePack);
    }, onError: (e) => Result.error(e));
  }
}
