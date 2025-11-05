import 'dart:async';
import 'package:aiflow/core/domain/entities/user.dart' as domain;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileRemoteDs {
  final FirebaseAuth _auth;
  final CollectionReference<Map<String, dynamic>> _users;
  ProfileRemoteDs(this._auth, this._users);

  Future<domain.User?> current() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    final snap = await _users.doc(u.uid).get();
    final d = snap.data();
    return _toDomain(u, d);
  }

  Stream<domain.User?> watch() async* {
    await for (final u in _auth.userChanges()) {
      if (u == null) {
        yield null;
      } else {
        yield* _users.doc(u.uid).snapshots().map((snap) {
          final d = snap.data();
          return _toDomain(u, d);
        });
      }
    }
  }

  Future<void> updateDisplayName(String newName) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw StateError('Not signed in');
    await currentUser.updateDisplayName(newName);
    await _users.doc(currentUser.uid).set({
      'name': newName,
    }, SetOptions(merge: true));
    await _auth.currentUser?.reload();
  }

  Future<void> changePassword(String oldPwd, String newPwd) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not signed in');
    final email = user.email;
    if (email == null || email.isEmpty) {
      throw StateError('This account has no email/password sign-in.');
    }
    final cred = EmailAuthProvider.credential(email: email, password: oldPwd);
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPwd);
  }

  Future<void> updatePhotoUrl(String? url) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw StateError('Not signed in');

    await currentUser.updatePhotoURL(
      (url != null && url.trim().isNotEmpty) ? url : null,
    );

    await _users.doc(currentUser.uid).set({
      'photoUrl': url?.trim() ?? '',
    }, SetOptions(merge: true));

    await _auth.currentUser?.reload();
  }

  Future<void> clearPhoto() => updatePhotoUrl('');

  domain.User _toDomain(User u, Map<String, dynamic>? json) {
    final name = (json?['name'] as String?)?.trim();
    final photo = (json?['photoUrl'] as String?)?.trim();
    final email = (json?['email'] as String?)?.trim();

    DateTime? createdAt;
    final ts = json?['createdAt'];
    if (ts is Timestamp) createdAt = ts.toDate();

    return domain.User(
      id: u.uid,
      name: name?.isNotEmpty == true ? name! : (u.displayName ?? 'User'),
      email: (email?.isNotEmpty == true ? email! : (u.email ?? '')),
      photoUrl: (photo?.isNotEmpty == true ? photo! : (u.photoURL ?? '')),
      createdAt: createdAt,
    );
  }
}
