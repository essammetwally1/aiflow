import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';
import '../../../auth/domain/usecases/current_user.dart';
import '../../../auth/domain/usecases/sign_in.dart';
import '../../../auth/domain/usecases/sign_out.dart';
import '../../../auth/domain/usecases/sign_up.dart';
import '../../../auth/domain/usecases/watch_auth_state.dart';
import '../../../../core/services/storage/user_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final SignIn _signIn;
  final SignUp _signUp;
  final SignOut _signOut;
  final WatchAuthState _watch;
  final CurrentUser _current;

  AuthProvider(
    this._signIn,
    this._signUp,
    this._signOut,
    this._watch,
    this._current,
  ) {
    _watch().listen((u) {
      user = u;
      notifyListeners();
    });
  }

  UserModel? user;
  String? error;
  bool loading = false;

  Future<void> init() async {
    final bool remember = await UserStorageService.isRememberMeEnabled();
    final UserModel? existing = _current();
    if (!remember && existing != null) {
      await _signOut();
    } else {
      user = existing;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      user = await _signIn(email, password);
      await UserStorageService.setRememberMe(rememberMe);
      return true;
    } catch (e) {
      error = _mapError(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      user = await _signUp(name, email, password);
      return true;
    } catch (e) {
      error = _mapError(e);
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _signOut();
    await UserStorageService.setRememberMe(false);
    user = null;
    notifyListeners();
  }

  String _mapError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return 'The email or password is incorrect.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'weak-password':
          return 'Password is too weak. Use at least 9 characters.';
        case 'network-request-failed':
          return 'Network error. Check your internet connection.';
        case 'too-many-requests':
          return 'Too many attempts. Try again later.';
        default:
          return e.message ?? 'Authentication error occurred.';
      }
    }
    final msg = e.toString();
    if (msg.contains('SocketException')) return 'No internet connection.';
    return 'Unexpected error: $msg';
  }
}
