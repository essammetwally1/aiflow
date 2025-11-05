import 'package:aiflow/core/domain/entities/user.dart' as domain;
import 'package:aiflow/core/types/result.dart';
import 'package:aiflow/features/profile/domain/failures/profile_failure.dart';

abstract class ProfileRepository {
  domain.User? getCurrent();
  Stream<domain.User?> watch();
  Future<Result<ProfileFailure, void>> rename(String newName);
  Future<Result<ProfileFailure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });
  Future<Result<ProfileFailure, void>> setPhotoUrl(String url);
  Future<Result<ProfileFailure, void>> clearPhotoUrl();
}
