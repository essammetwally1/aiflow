import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aiflow/core/domain/entities/user.dart' as domain;

class UserModel {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      if (v is Timestamp) return v.toDate();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    return UserModel(
      id: json['id'] as String,
      name: (json['name'] as String? ?? 'User').trim(),
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      createdAt: toDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
    if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
  };

  domain.User toDomain() => domain.User(
    id: id,
    name: name,
    email: email,
    photoUrl: photoUrl,
    createdAt: createdAt,
  );

  static UserModel fromDomain(domain.User u) => UserModel(
    id: u.id,
    name: u.name,
    email: u.email,
    photoUrl: u.photoUrl,
    createdAt: u.createdAt,
  );
}
