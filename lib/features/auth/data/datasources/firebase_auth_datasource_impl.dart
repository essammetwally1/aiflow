import 'package:aiflow/core/services/firebase/firebase_refs.dart';
import 'package:aiflow/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:aiflow/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart' as gsi;

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _auth = FirebaseRefs.auth;

  CollectionReference<Map<String, dynamic>> get _users => FirebaseRefs.users;

  @override
  Stream<UserModel?> watchAuth() => _auth.idTokenChanges().asyncMap((u) async {
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
  Future<UserModel> signInWithGoogle() async {
    try {
      UserCredential cred;
      String derivedName = '';
      String derivedPhoto = '';

      if (kIsWeb) {
        final provider = GoogleAuthProvider()
          ..setCustomParameters({'prompt': 'select_account'});
        cred = await _auth.signInWithProvider(
          provider,
        ); // or signInWithPopup(provider)
      } else {
        // If your google-services.json already has a Web OAuth client (client_type:3), keep constructor empty.
        // If you ever get “serverClientId must be provided”, add it below.
        final g = gsi.GoogleSignIn(
          // serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
        );

        final account = await g.signIn();
        if (account == null) {
          throw FirebaseAuthException(
            code: 'canceled-by-user',
            message: 'Sign-in canceled by user',
          );
        }

        derivedName = (account.displayName ?? '').trim();
        derivedPhoto = (account.photoUrl ?? '').trim();

        final auth = await account.authentication;
        final oauth = GoogleAuthProvider.credential(
          idToken: auth.idToken,
          accessToken: auth.accessToken,
        );

        cred = await _auth.signInWithCredential(oauth);
      }

      final u = cred.user!;
      var name = (u.displayName ?? '').trim();
      if (name.isEmpty) name = derivedName;
      if (name.isEmpty) {
        final email = (u.email ?? '').trim();
        final beforeAt = email.contains('@') ? email.split('@').first : email;
        name = beforeAt.replaceAll(RegExp(r'[._]+'), ' ').trim();
        if (name.isEmpty) name = 'User';
        name = name[0].toUpperCase() + name.substring(1);
      }

      final photoUrl = (u.photoURL ?? '').trim().isNotEmpty
          ? u.photoURL!.trim()
          : derivedPhoto;

      if ((u.displayName ?? '').trim().isEmpty && name.isNotEmpty) {
        await u.updateDisplayName(name);
      }

      await _upsertUser(u, overrideName: name, overridePhoto: photoUrl);
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
  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        final g = gsi.GoogleSignIn();
        if (await g.isSignedIn()) {
          await g.signOut();
          // await g.disconnect();
        }
      } catch (_) {}
    }
    await _auth.signOut();
  }

  // ---- helpers ----
  UserModel _toModel(User u) => UserModel(
    id: u.uid,
    name: (u.displayName ?? '').trim().isEmpty ? 'User' : u.displayName!.trim(),
    email: u.email ?? '',
    photoUrl: u.photoURL ?? '',
  );

  Future<void> _upsertUser(
    User u, {
    String? overrideName,
    String? overridePhoto,
  }) async {
    final name = (overrideName ?? u.displayName ?? '').trim();
    final photo = (overridePhoto ?? u.photoURL ?? '').trim();

    final doc = _users.doc(u.uid);
    final snap = await doc.get();

    final data = <String, dynamic>{
      'id': u.uid,
      'name': name.isEmpty ? 'User' : name,
      'email': u.email ?? '',
      'photoUrl': photo,
    };

    if (!snap.exists) {
      // First-time create: set createdAt once
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await doc.set(data, SetOptions(merge: true));
  }
}
