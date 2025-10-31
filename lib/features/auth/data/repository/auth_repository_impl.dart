import '../models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _ds;
  AuthRepositoryImpl(this._ds);

  @override
  Stream<UserModel?> watchAuthState() => _ds.watchAuth();

  @override
  Future<UserModel> signIn(String email, String password) =>
      _ds.signIn(email, password);

  @override
  Future<UserModel> signUp(String name, String email, String password) =>
      _ds.signUp(name, email, password);

  @override
  Future<void> signOut() => _ds.signOut();

  @override
  UserModel? currentUser() => _ds.currentUser;
}
