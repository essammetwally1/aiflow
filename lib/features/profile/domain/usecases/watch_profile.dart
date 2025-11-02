import 'package:aiflow/core/domain/entities/user.dart' as domain;
import '../repositories/profile_repository.dart';

class WatchProfile {
  final ProfileRepository repo;
  WatchProfile(this.repo);
  Stream<domain.User?> call() => repo.watch();
}
