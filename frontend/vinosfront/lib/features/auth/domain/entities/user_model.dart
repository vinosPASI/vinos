class UserResponse {
  final String accessToken;
  final String userId;

  UserResponse({
    required this.accessToken,
    required this.userId,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      accessToken: json['access_token'] ?? '',
      userId: json['user_id'] ?? '',
    );
  }
}
