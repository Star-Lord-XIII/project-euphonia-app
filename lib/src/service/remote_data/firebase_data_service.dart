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
      {required String userUid, required String languagePackCode}) async {
    final utterancesRef = _storageRef.child('$userUid/$languagePackCode');
    final ListResult result = await utterancesRef.listAll();

    final docDir = await getApplicationDocumentsDirectory();
    final String localUserDir = '${docDir.path}/$userUid/$languagePackCode';
    if (!Directory(localUserDir).existsSync()) {
      Directory(localUserDir).createSync(recursive: true);
    }

    for (final fileRef in result.items) {
      if (!fileRef.name.endsWith('.wav')) {
        continue;
      }
      final localFile = File('$localUserDir/${fileRef.name}');
      if (localFile.existsSync()) {
        print('ALREADY EXISTS: ${fileRef.name}');
        continue;
      }
      await fileRef.writeToFile(localFile);
      print('DOWNLOADED: ${fileRef.name}');
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
