import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // for StorageException

import 'package:aiflow/core/services/image_picker/image_picker_service.dart';
import 'package:aiflow/features/profile/domain/failures/profile_failure.dart';
import 'package:aiflow/features/profile/domain/repositories/profile_repository.dart';
import 'package:aiflow/features/profile/data/storage/avatar_storage.dart';

class ProfileController {
  ProfileController(this._auth, this._repo, this._picker, this._storage);

  final FirebaseAuth _auth;
  final ProfileRepository _repo;
  final ImagePickerService _picker; // core picker (bytes + crop)
  final AvatarStorage _storage;

  Future<String?> changeAvatar(
    ImageSource source, {
    required bool isDark,
    void Function()? onStartedUpload, // <— NEW
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 'You are not signed in.';

    try {
      // 1) pick + crop (theme-aware)
      final Uint8List? bytes = await _picker.pickAndCrop(
        source,
        isDark: isDark,
      );
      if (bytes == null) return null; // user cancelled BEFORE upload

      // >>> Tell UI we're about to start the upload
      onStartedUpload?.call();

      // 2) upload
      final previous = _auth.currentUser?.photoURL ?? '';
      final url = await _storage.uploadAvatar(
        userId: uid,
        bytes: bytes,
        previousUrl: previous.isNotEmpty ? previous : null,
      );

      // 3) persist URL
      final r = await _repo.setPhotoUrl(url);
      if (!r.isOk) {
        await _storage.deleteAvatarByUrl(url);
        return _describe(r.left ?? const Unknown('Failed to save photo URL'));
      }

      return null;
    } on StorageException catch (e) {
      if (e.statusCode == 403) {
        return 'Upload blocked by storage policy (403). Ensure Supabase policy for avatars bucket.';
      }
      return 'Storage error: ${e.message}';
    } on FirebaseAuthException catch (e) {
      return 'Auth error: ${e.message ?? e.code}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<String?> deleteAvatar() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 'You are not signed in.';

    final prevUrl = _auth.currentUser?.photoURL ?? '';
    try {
      final r = await _repo.clearPhotoUrl();
      if (!r.isOk) {
        return _describe(r.left ?? const Unknown('Failed to clear photo URL'));
      }
      if (prevUrl.isNotEmpty) {
        try {
          await _storage.deleteAvatarByUrl(prevUrl);
        } on StorageException {
          // non-fatal
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return 'Auth error: ${e.message ?? e.code}';
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  String _describe(ProfileFailure f) => switch (f) {
    NotSignedIn() => 'You are not signed in.',
    Network() => 'Network error. Check your internet connection.',
    Unknown(:final message) => message,
  };
}
