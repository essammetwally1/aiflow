import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Stream<UserModel?> watchAuthState();
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String name, String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  UserModel? currentUser();
}
