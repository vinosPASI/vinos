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

  /
  factory UserModel.fromJson(Map<String, dynamic> json, String email) {
    return UserModel(
      id: json['user_id'] ?? '',
      email: email,
      token: json['access_token'] ?? '',
      role: json['role'] ?? 0,
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
