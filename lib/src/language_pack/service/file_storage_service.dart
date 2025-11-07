import '../../common/result.dart';

abstract class FileStorageService {
  Future<Result<String>> readFile({required String path});

  Future<Result<void>> writeFile({required String path,
    required String content});
}