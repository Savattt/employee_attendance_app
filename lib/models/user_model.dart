class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String role; // 'employee', 'admin', 'hr'

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'],
      role: map['role'] ?? 'employee',
    );
  }

  Map<String, dynamic> toMap() {
    return {'email': email, 'displayName': displayName, 'role': role};
  }
}
