class ProfileUser {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final DateTime? createdAt;

  const ProfileUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.createdAt,
  });

  ProfileUser copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return ProfileUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
