import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

import '../../common/result.dart';
import 'database_service.dart';

final class FirebaseFirestoreService extends DatabaseService {
  final _log = Logger('language_pack.FirebaseFirestoreService');

  final FirebaseFirestore firestoreInstance;

  FirebaseFirestoreService({required this.firestoreInstance});

  @override
  Future<Result<Map<String, dynamic>>> getRow(
      {required String table, required String id}) async {
    _log.finer('Get document $id from collection $table');
    try {
      final documentSnapshot =
          await firestoreInstance.collection(table).doc(id).get();
      if (!documentSnapshot.exists) {
        final errorMessage =
            'No document found with id $id in collection $table';
        _log.warning(errorMessage);
        return Result.error(Exception(errorMessage));
      }
      return Result.ok(documentSnapshot.data()!);
    } on FirebaseException catch (e) {
      _log.warning(e);
      return Result.error(e);
    } on Exception catch (e) {
      _log.warning(e);
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> update(
      {required String table,
      required String id,
      required Map<String, dynamic> updatedValues}) async {
    try {
      await firestoreInstance.collection(table).doc(id).update(updatedValues);
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      _log.warning(e);
      return Result.error(e);
    } on Exception catch (e) {
      _log.warning(e);
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> insert(
      {required String table,
      required String id,
      required Map<String, dynamic> newValue}) async {
    try {
      await firestoreInstance.collection(table).doc(id).set(newValue);
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      _log.warning(e);
      return Result.error(e);
    } on Exception catch (e) {
      _log.warning(e);
      return Result.error(e);
    }
  }
}
