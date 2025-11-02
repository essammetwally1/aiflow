// lib/features/profile/presentation/provider/profile_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aiflow/core/domain/entities/user.dart' as domain;
import 'package:aiflow/features/profile/domain/failures/profile_failure.dart';
import 'package:aiflow/features/profile/domain/usecases/watch_profile.dart';
import 'package:aiflow/features/profile/domain/usecases/rename_user.dart';
import 'package:aiflow/features/profile/domain/usecases/change_password.dart';
import '../controllers/profile_controller.dart';

class ProfileProvider extends ChangeNotifier {
  final WatchProfile _watch;
  final RenameUser _rename;
  final ChangePassword _changePassword;

  ProfileState state = ProfileState.initial;
  StreamSubscription<domain.User?>? _sub;

  ProfileProvider(this._watch, this._rename, this._changePassword);

  void init() {
    _sub?.cancel();
    _sub = _watch().listen(
      (u) {
        state = ProfileState(
          status: ProfileStatus.ready,
          profile: u,
          message: null,
        );
        notifyListeners();
      },
      onError: (e) {
        state = ProfileState(
          status: ProfileStatus.error,
          profile: state.profile,
          message: '$e',
        );
        notifyListeners();
      },
    );
  }

  bool _sameName(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();

  Future<void> rename(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final prev = state.profile;
    if (prev != null && _sameName(prev.name, trimmed)) return;

    // optimistic
    state = state.copyWith(
      status: ProfileStatus.loading,
      profile: prev?.copyWith(name: trimmed),
      message: null,
    );
    notifyListeners();

    final r = await _rename(trimmed);
    if (r.isOk) {
      state = state.copyWith(status: ProfileStatus.ready, message: null);
    } else {
      final msg = _describe(r.left ?? const Unknown('Rename failed'));
      state = state.copyWith(
        status: ProfileStatus.error,
        profile: prev,
        message: msg,
      );
    }
    notifyListeners();
  }

  /// Call this from UI when you want to show success ONLY after the profile stream
  /// emits the updated name. Returns true on confirmed success, false otherwise.
  Future<bool> renameAndConfirm(
    String newName, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final target = newName.trim();
    if (target.isEmpty) return false;

    // Listen ONCE for the updated name before firing rename(), so we don't miss it.
    final completer = Completer<bool>();
    late StreamSubscription<domain.User?> confirmSub;

    confirmSub = _watch().listen(
      (u) {
        if (u != null && _sameName(u.name, target) && !completer.isCompleted) {
          completer.complete(true);
          confirmSub.cancel();
        }
      },
      onError: (_) {
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await rename(target);

    try {
      final ok = await completer.future.timeout(
        timeout,
        onTimeout: () => false,
      );
      return ok;
    } finally {
      // Ensure subscription is cleaned up in all branches
      await confirmSub.cancel();
    }
  }

  /// returns error message (if any); null on success
  Future<String?> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(status: ProfileStatus.loading, message: null);
    notifyListeners();

    final r = await _changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
    if (r.isOk) {
      state = state.copyWith(status: ProfileStatus.ready, message: null);
      notifyListeners();
      return null;
    } else {
      final msg = _describe(r.left ?? const Unknown('Password change failed'));
      state = state.copyWith(status: ProfileStatus.error, message: msg);
      notifyListeners();
      return msg;
    }
  }

  String _describe(ProfileFailure f) => switch (f) {
    NotSignedIn() => 'You are not signed in.',
    Network() => 'Network error. Check your internet connection.',
    Unknown(:final message) => message,
  };

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
