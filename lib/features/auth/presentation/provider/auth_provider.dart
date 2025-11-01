import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';
import '../../../auth/domain/usecases/current_user.dart';
import '../../../auth/domain/usecases/sign_in.dart';
import '../../../auth/domain/usecases/sign_out.dart';
import '../../../auth/domain/usecases/sign_up.dart';
import '../../../auth/domain/usecases/watch_auth_state.dart';
import '../../../auth/domain/usecases/sign_in_with_google.dart';
import '../../../../core/services/storage/user_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final SignIn _signIn;
  final SignUp _signUp;
  final SignOut _signOut;
  final WatchAuthState _watch;
  final CurrentUser _current;
  final SignInWithGoogle _signInWithGoogle;

  AuthProvider(
    this._signIn,
    this._signUp,
    this._signOut,
    this._watch,
    this._current,
    this._signInWithGoogle,
  ) {
    _sub = _watch().listen((u) {
      user = u;
      initializing = false;
      notifyListeners();
    });
  }

  StreamSubscription<UserModel?>? _sub;

  UserModel? user;
  String? error;
  bool loading = false;
  bool initializing = true;

  Future<void> init() async {
    final remember = await UserStorageService.isRememberMeEnabled();
    final existing = _current();
    if (!remember && existing != null) {
      await _signOut();
    } else {
      user = existing;
    }
    initializing = false;
    notifyListeners();
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
    } on FirebaseAuthException catch (e) {
      error = _mapError(e);
      return false;
    } catch (e) {
      error = 'Unexpected error: $e';
      return false;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> googleSignIn() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      user = await _signInWithGoogle();
      await UserStorageService.setRememberMe(true);
      return true;
    } on FirebaseAuthException catch (e) {
      error = _mapError(e);
      return false;
    } catch (e) {
      error = 'Unexpected error: $e';
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
    } on FirebaseAuthException catch (e) {
      error = _mapError(e);
      return false;
    } catch (e) {
      error = 'Unexpected error: $e';
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

  String _mapError(FirebaseAuthException e) {
    if (e.code == 'canceled' || e.code == 'canceled-by-user') {
      return 'Google sign-in cancelled.';
    }
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
      case 'account-exists-with-different-credential':
        return 'This email is already linked to another sign-in method.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
