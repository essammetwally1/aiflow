import 'package:aiflow/core/types/result.dart';

import '../failures/profile_failure.dart';
import '../repositories/profile_repository.dart';

class RenameUser {
  final ProfileRepository repo;
  RenameUser(this.repo);
  Future<Result<ProfileFailure, void>> call(String name) => repo.rename(name);
}
