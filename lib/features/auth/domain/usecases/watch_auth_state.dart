import '../../data/models/user_model.dart';
import '../repositories/auth_repository.dart';

class WatchAuthState {
  final AuthRepository _repo;
  WatchAuthState(this._repo);

  Stream<UserModel?> call() => _repo.watchAuthState();
}
