// lib/features/auth/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

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
    // Do NOT set createdAt here on every write; upsert will handle it.
    if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
  };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
