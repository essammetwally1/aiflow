import 'package:aiflow/core/services/firebase/firebase_refs.dart';
import 'package:aiflow/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:aiflow/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _auth = FirebaseRefs.auth;
  final List<String> _identityScopes = <String>['email', 'profile', 'openid'];

  CollectionReference<Map<String, dynamic>> get _users => FirebaseRefs.users;

  @override
  Stream<UserModel?> watchAuth() =>
      _auth.authStateChanges().asyncMap((u) async {
        if (u == null) return null;
        await _upsertUser(u);
        return _toModel(u);
      });

  @override
  UserModel? get currentUser =>
      _auth.currentUser == null ? null : _toModel(_auth.currentUser!);

  @override
  Future<UserModel> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final u = cred.user!;
    await _upsertUser(u);
    return _toModel(u);
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      UserCredential cred;
      String derivedName = '';

      if (kIsWeb) {
        // On Web, keep using Firebase popup/provider (stable & simple).
        final provider = GoogleAuthProvider()
          ..setCustomParameters({'prompt': 'select_account'});
        // Use whichever your firebase_auth exposes (both are fine on web):
        // cred = await _auth.signInWithPopup(provider);
        cred = await _auth.signInWithProvider(provider);
      } else {
        // ANDROID / iOS: follow the example's platform-interface flow

        // 1) Ensure the platform instance is initialized (like the sample does)
        await GoogleSignInPlatform.instance
            .init(const InitParameters())
            .catchError((_) {
              /* no-op: allow retry next time */
            });

        // 2) Interactive sign-in (this shows Google's native UI)
        final AuthenticationResults results = await GoogleSignInPlatform
            .instance
            .authenticate(const AuthenticateParameters());

        final GoogleSignInUserData? gUser = results.user;
        if (gUser == null) {
          throw FirebaseAuthException(
            code: 'canceled-by-user',
            message: 'Sign-in canceled by user',
          );
        }

        derivedName = (gUser.displayName ?? '').trim();

        // 3) Request tokens for basic identity scopes (no contacts needed)
        final ClientAuthorizationTokenData? tok = await GoogleSignInPlatform
            .instance
            .clientAuthorizationTokensForScopes(
              ClientAuthorizationTokensForScopesParameters(
                request: AuthorizationRequestDetails(
                  scopes: _identityScopes,
                  userId: gUser.id,
                  email: gUser.email,
                  promptIfUnauthorized: true,
                ),
              ),
            );

        if (tok == null || (tok.accessToken).isEmpty) {
          throw FirebaseAuthException(
            code: 'missing-access-token',
            message: 'Could not obtain Google access token',
          );
        }

        // 4) Build Firebase credential from Google access token
        final OAuthCredential oauth = GoogleAuthProvider.credential(
          accessToken:
              tok.accessToken, // idToken is optional; accessToken is enough
          // idToken: tok.idToken, // (platform interface does not currently expose this)
        );

        // 5) Sign in to Firebase
        cred = await _auth.signInWithCredential(oauth);
      }

      // 6) Finalize profile + upsert
      final User u = cred.user!;
      String name = (u.displayName ?? '').trim();
      if (name.isEmpty) name = derivedName;

      if (name.isEmpty) {
        final email = (u.email ?? '').trim();
        final beforeAt = email.contains('@') ? email.split('@').first : email;
        name = beforeAt.replaceAll(RegExp(r'[._]+'), ' ').trim();
        if (name.isEmpty) name = 'User';
        name = name[0].toUpperCase() + name.substring(1);
      }

      if ((u.displayName ?? '').trim().isEmpty && name.isNotEmpty) {
        await u.updateDisplayName(name);
      }

      await _upsertUser(u, overrideName: name);
      return _toModel(u);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'google-signin-failed',
        message: 'Google sign-in failed: $e',
      );
    }
  }

  @override
  Future<UserModel> signUp(String name, String email, String password) async {
    final UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final User user = cred.user!;
    await user.updateDisplayName(name);
    await user.reload();
    final fresh = _auth.currentUser!;
    await _upsertUser(fresh, overrideName: name);
    return _toModel(fresh);
  }

  @override
  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await GoogleSignInPlatform.instance.disconnect(
          const DisconnectParams(),
        );
      } catch (_) {
        // ignore: user might not be connected at the platform level
      }
    }
    await _auth.signOut();
  }

  // ---- helpers ----
  UserModel _toModel(User u) => UserModel(
    id: u.uid,
    name: (u.displayName ?? '').trim().isEmpty ? 'User' : u.displayName!.trim(),
    email: u.email ?? '',
  );

  Future<void> _upsertUser(User u, {String? overrideName}) async {
    final name = (overrideName ?? u.displayName ?? '').trim();
    final data = {
      'id': u.uid,
      'name': name.isEmpty ? 'User' : name,
      'email': u.email ?? '',
      'photoUrl': u.photoURL ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final doc = _users.doc(u.uid);
    final snap = await doc.get();
    if (!snap.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await doc.set(data, SetOptions(merge: true));
  }
}
