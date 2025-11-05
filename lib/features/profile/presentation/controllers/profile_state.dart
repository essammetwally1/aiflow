import 'package:aiflow/core/domain/entities/user.dart' as domain;

enum ProfileStatus { initial, ready, loading, error }

class ProfileState {
  final ProfileStatus status;
  final domain.User? profile;
  final String? message;

  const ProfileState({
    required this.status,
    required this.profile,
    required this.message,
  });

  static const ProfileState initial = ProfileState(
    status: ProfileStatus.initial,
    profile: null,
    message: null,
  );

  ProfileState copyWith({
    ProfileStatus? status,
    domain.User? profile,
    String? message,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      message: message,
    );
  }
}
