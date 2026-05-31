import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.lyraTag,
    super.avatarUrl,
    required super.isActive,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:          json['id'] as String,
      firstName:   json['first_name'] as String,
      lastName:    json['last_name'] as String,
      email:       json['email'] as String,
      lyraTag:     json['lyra_tag'] as String,
      avatarUrl:   json['avatar_url'] as String?,
      isActive:    json['is_active'] as bool? ?? true,
      createdAt:   DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':         id,
    'first_name': firstName,
    'last_name':  lastName,
    'email':      email,
    'lyra_tag':   lyraTag,
    'avatar_url': avatarUrl,
    'is_active':  isActive,
    'created_at': createdAt.toIso8601String(),
  };
}
