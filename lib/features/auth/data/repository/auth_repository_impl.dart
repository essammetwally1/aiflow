import 'package:aiflow/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:aiflow/features/auth/data/models/user_model.dart';
import 'package:aiflow/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _ds;
  AuthRepositoryImpl(this._ds);

  @override
  Stream<UserModel?> watchAuthState() => _ds.watchAuth();

  @override
  UserModel? currentUser() => _ds.currentUser;

  @override
  Future<UserModel> signIn(String email, String password) =>
      _ds.signIn(email, password);

  @override
  Future<UserModel> signUp(String name, String email, String password) =>
      _ds.signUp(name, email, password);

  @override
  Future<UserModel> signInWithGoogle() => _ds.signInWithGoogle();

  @override
  Future<void> signOut() => _ds.signOut();
}
