import 'package:aiflow/core/domain/entities/user.dart' as domain;
import 'package:aiflow/core/types/result.dart';
import 'package:aiflow/features/profile/domain/failures/profile_failure.dart';
import '../datasources/profile_remote_ds.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDs ds;
  ProfileRepositoryImpl(this.ds);

  @override
  domain.User? getCurrent() => null;

  @override
  Stream<domain.User?> watch() => ds.watch();

  @override
  Future<Result<ProfileFailure, void>> rename(String newName) async {
    try {
      await ds.updateDisplayName(newName);
      return Result.ok();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') return Result.err(Network());
      return Result.err(Unknown(e.message ?? 'Auth error'));
    } on FirebaseException catch (e) {
      if (e.code.contains('network')) return Result.err(Network());
      return Result.err(Unknown(e.message ?? 'Firestore error'));
    } on StateError catch (e) {
      if (e.message.contains('Not signed in')) return Result.err(NotSignedIn());
      return Result.err(Unknown(e.message));
    } catch (e) {
      return Result.err(Unknown(e.toString()));
    }
  }

  @override
  Future<Result<ProfileFailure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await ds.changePassword(oldPassword, newPassword);
      return Result.ok();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return Result.err(Unknown('Old password is incorrect.'));
      }
      if (e.code == 'weak-password') {
        return Result.err(
          Unknown('New password is too weak. Use at least 9 characters.'),
        );
      }
      if (e.code == 'network-request-failed') return Result.err(Network());
      return Result.err(Unknown(e.message ?? 'Password change failed.'));
    } on StateError catch (e) {
      if (e.message.contains('Not signed in')) return Result.err(NotSignedIn());
      if (e.message.contains('no email/password')) {
        return Result.err(
          Unknown('This account uses a social sign-in and has no password.'),
        );
      }
      return Result.err(Unknown(e.message));
    } catch (e) {
      return Result.err(Unknown(e.toString()));
    }
  }

  // NEW
  @override
  Future<Result<ProfileFailure, void>> setPhotoUrl(String url) async {
    try {
      await ds.updatePhotoUrl(url);
      return Result.ok();
    } on FirebaseException catch (e) {
      if (e.code.contains('network')) return Result.err(Network());
      return Result.err(Unknown(e.message ?? 'Failed to save photo URL'));
    } on StateError catch (e) {
      if (e.message.contains('Not signed in')) return Result.err(NotSignedIn());
      return Result.err(Unknown(e.message));
    } catch (e) {
      return Result.err(Unknown(e.toString()));
    }
  }

  @override
  Future<Result<ProfileFailure, void>> clearPhotoUrl() async {
    try {
      await ds.clearPhoto();
      return Result.ok();
    } on FirebaseException catch (e) {
      if (e.code.contains('network')) return Result.err(Network());
      return Result.err(Unknown(e.message ?? 'Failed to clear photo URL'));
    } on StateError catch (e) {
      if (e.message.contains('Not signed in')) return Result.err(NotSignedIn());
      return Result.err(Unknown(e.message));
    } catch (e) {
      return Result.err(Unknown(e.toString()));
    }
  }
}
