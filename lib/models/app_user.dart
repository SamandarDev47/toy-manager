class AppUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String role;
  final String provider;
  final String? photoUrl;
  final int createdAt;
  final int updatedAt;

  const AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email = '',
    this.role = 'user',
    this.provider = 'password',
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    if (name.isNotEmpty) return name;
    if (email.isNotEmpty) return email.split('@').first;
    if (phone.isNotEmpty) return phone;
    return 'Foydalanuvchi';
  }

  String get initials {
    final a = firstName.trim().isNotEmpty ? firstName.trim()[0] : '';
    final b = lastName.trim().isNotEmpty ? lastName.trim()[0] : '';
    final result = '$a$b'.trim();
    if (result.isNotEmpty) return result.toUpperCase();
    if (email.isNotEmpty) return email[0].toUpperCase();
    return 'U';
  }

  factory AppUser.fromMap(Map<dynamic, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      firstName: (map['firstName'] ?? '').toString(),
      lastName: (map['lastName'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      role: (map['role'] ?? 'user').toString(),
      provider: (map['provider'] ?? 'password').toString(),
      photoUrl: map['photoUrl']?.toString(),
      createdAt: _asInt(map['createdAt']),
      updatedAt: _asInt(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'role': role,
        'provider': provider,
        'photoUrl': photoUrl,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  AppUser copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? role,
    String? provider,
    String? photoUrl,
    int? createdAt,
    int? updatedAt,
  }) {
    return AppUser(
      uid: uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      provider: provider ?? this.provider,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
