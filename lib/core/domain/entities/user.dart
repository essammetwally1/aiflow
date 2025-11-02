class User {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.createdAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
