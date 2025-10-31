import '../../data/models/user_model.dart';
import '../repositories/auth_repository.dart';

class CurrentUser {
  final AuthRepository _repo;
  CurrentUser(this._repo);

  UserModel? call() => _repo.currentUser();
}
