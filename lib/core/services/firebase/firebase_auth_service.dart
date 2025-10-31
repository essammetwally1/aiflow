import 'package:aiflow/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_refs.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseRefs.auth;

  CollectionReference<Map<String, dynamic>> get _usersCol => FirebaseRefs.users;

  Future<void> _upsertUserDoc({
    required User user,
    String? overrideName,
  }) async {
    final DocumentReference doc = _usersCol.doc(user.uid);
    final DocumentSnapshot snap = await doc.get();

    final String name = (overrideName ?? user.displayName ?? '').trim();
    final UserModel userModel = UserModel(
      id: user.uid,
      name: name.isEmpty ? 'User' : name,
      email: user.email ?? '',
    );

    if (!snap.exists) {
      await doc.set(userModel.toJson(), SetOptions(merge: true));
    } else {
      await doc.set(userModel.toJson(), SetOptions(merge: true));
    }
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final UserCredential userCredential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);

    final User? user = userCredential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'User is null after registration',
      );
    }

    await user.updateDisplayName(name);
    await user.reload();
    final fresh = _auth.currentUser!;
    await _upsertUserDoc(user: fresh, overrideName: name);
    return fresh;
  }

  Future<User> login({required String email, required String password}) async {
    final UserCredential userCredential = await _auth
        .signInWithEmailAndPassword(email: email, password: password);
    final User? user = userCredential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'User is null after login',
      );
    }
    await _upsertUserDoc(user: user);
    return user;
  }

  Future<void> signOut() => _auth.signOut();

  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
