import 'package:aiflow/features/auth/data/models/user_model.dart';

abstract class FirebaseAuthDataSource {
  Stream<UserModel?> watchAuth();
  UserModel? get currentUser;
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String name, String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
}
