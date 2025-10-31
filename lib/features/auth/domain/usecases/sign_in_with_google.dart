import '../../data/models/user_model.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository _repo;
  SignInWithGoogle(this._repo);

  Future<UserModel> call() => _repo.signInWithGoogle();
}
