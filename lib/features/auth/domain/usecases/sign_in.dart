import '../../data/models/user_model.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository _repo;
  SignIn(this._repo);

  Future<UserModel> call(String email, String password) =>
      _repo.signIn(email, password);
}
