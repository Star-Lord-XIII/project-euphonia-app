import '../../common/result.dart';
import '../../language_pack/model/language_pack.dart';

abstract class RemoteDataService {
  Future<Result<LanguagePack>> getMasterLanguagePack({
    required String languagePackCode,
  });

  Future<Result<void>> downloadAllUtterances({
    required String userUid,
    required String languagePackCode,
  });
}
