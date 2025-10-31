import 'package:aiflow/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/firebase/firebase_refs.dart';
import '../models/user_model.dart';

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth _auth = FirebaseRefs.auth;

  CollectionReference<Map<String, dynamic>> get _users => FirebaseRefs.users;

  @override
  Stream<UserModel?> watchAuth() =>
      _auth.authStateChanges().asyncMap((u) async {
        if (u == null) return null;
        // keep Firestore doc alive and fresh
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
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final u = cred.user!;
    await u.updateDisplayName(name);
    await u.reload();
    final fresh = _auth.currentUser!;
    await _upsertUser(fresh, overrideName: name);
    return _toModel(fresh);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  // Helpers
  UserModel _toModel(User u) => UserModel(
    id: u.uid,
    name: (u.displayName ?? '').trim().isEmpty ? 'User' : u.displayName!.trim(),
    email: u.email ?? '',
  );

  Future<void> _upsertUser(User u, {String? overrideName}) async {
    final name = (overrideName ?? u.displayName ?? '').trim();
    final model = UserModel(
      id: u.uid,
      name: name.isEmpty ? 'User' : name,
      email: u.email ?? '',
    );
    await _users.doc(u.uid).set(model.toJson(), SetOptions(merge: true));
  }
}
