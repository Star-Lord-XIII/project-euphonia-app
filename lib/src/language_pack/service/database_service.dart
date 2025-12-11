import '../../common/result.dart';

abstract class DatabaseService {
  Future<Result<Map<String, dynamic>>> getRow(
      {required String table, required String id});

  Future<Result<void>> update(
      {required String table,
      required String id,
      required Map<String, dynamic> updatedValues});

  Future<Result<void>> insert(
      {required String table,
      required String id,
      required Map<String, dynamic> newValue});
}
