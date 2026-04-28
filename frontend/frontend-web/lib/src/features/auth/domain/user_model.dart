class UserModel {
  final String id;
  final String email;
  final String token;
  final int role; 

  UserModel({
    required this.id,
    required this.email,
    required this.token,
    required this.role,
  });

  static int _parseRole(dynamic roleDef) {
    if (roleDef is int) return roleDef;
    if (roleDef is String) {
      switch (roleDef.toUpperCase()) {
        case 'ROLE_ADMIN': return 1;
        case 'ROLE_OPERATOR': return 2;
        case 'ROLE_UNSPECIFIED': default: return 0;
      }
    }
    return 0;
  }

  factory UserModel.fromJson(Map<String, dynamic> json, String email) {
    return UserModel(
      id: json['user_id'] ?? '',
      email: email,
      token: json['access_token'] ?? '',
      role: _parseRole(json['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'email': email,
      'access_token': token,
      'role': role,
    };
  }

  bool get isAdmin => role == 1;
  bool get isOperator => role == 2;
}
