import 'package:aiflow/core/domain/entities/user.dart' as domain;
import '../repositories/profile_repository.dart';

class GetProfile {
  final ProfileRepository repo;
  GetProfile(this.repo);
  domain.User? call() => repo.getCurrent();
}
