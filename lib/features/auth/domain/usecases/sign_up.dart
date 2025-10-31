import '../../data/models/user_model.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository _repo;
  SignUp(this._repo);

  Future<UserModel> call(String name, String email, String password) =>
      _repo.signUp(name, email, password);
}
