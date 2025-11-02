import 'package:aiflow/core/types/result.dart';
import 'package:aiflow/features/profile/domain/failures/profile_failure.dart';
import 'package:aiflow/features/profile/domain/repositories/profile_repository.dart';

class ChangePassword {
  final ProfileRepository repo;
  ChangePassword(this.repo);

  Future<Result<ProfileFailure, void>> call({
    required String oldPassword,
    required String newPassword,
  }) {
    return repo.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}
